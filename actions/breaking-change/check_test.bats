#!/usr/bin/env bats
#
# Unit tests for the pure helpers in check.sh. Run with `bats check_test.bats`.

setup() {
  source "${BATS_TEST_DIRNAME}/check.sh"
}

@test "title_is_breaking: plain type with bang" {
  run title_is_breaking "feat!: drop legacy field"
  [ "$status" -eq 0 ]
}

@test "title_is_breaking: type with scope and bang" {
  run title_is_breaking "feat(history)!: change shard interface"
  [ "$status" -eq 0 ]
}

@test "title_is_breaking: non-breaking type is ignored" {
  run title_is_breaking "feat(history): add retry logic"
  [ "$status" -ne 0 ]
}

@test "title_is_breaking: bang only counts before the colon" {
  run title_is_breaking "fix: handle ! in body"
  [ "$status" -ne 0 ]
}

@test "title_is_breaking: empty title" {
  run title_is_breaking ""
  [ "$status" -ne 0 ]
}

@test "to_pathspecs: trims and skips blank lines" {
  run bash -c 'source "'"${BATS_TEST_DIRNAME}"'/check.sh"; printf "  schema/**  \n\n client/**/interface.go\n" | to_pathspecs'
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = ':(glob)schema/**' ]
  [ "${lines[1]}" = ':(glob)client/**/interface.go' ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "missing_sections: all present yields nothing" {
  body=$'## Detailed Description\nx\n## Impact Analysis\ny'
  run missing_sections "$body" "Detailed Description,Impact Analysis"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "missing_sections: reports only what is missing, trimming spaces" {
  body=$'Detailed Description present'
  run missing_sections "$body" "Detailed Description, Impact Analysis , Rollout Plan"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Impact Analysis' ]
  [ "${lines[1]}" = 'Rollout Plan' ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "trim: strips leading and trailing whitespace" {
  run trim "   hello world   "
  [ "$output" = 'hello world' ]
}
