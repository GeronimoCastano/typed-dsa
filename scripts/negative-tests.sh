#!/usr/bin/env bash
#
# Runs the negative diagnostic suite in tests/negative.typ.
#
# Each case must fail to compile AND explain itself: the runner checks that
# `typst compile` exits non-zero and that the error text contains the case's
# expected fragment. A case that compiles cleanly, or that fails with an
# unhelpful generic Typst error, is a failure.
#
#   scripts/negative-tests.sh          run every case
#   scripts/negative-tests.sh 42       run one case by index

set -uo pipefail

repository_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repository_root"

case_table="$(mktemp)"
compile_output="$(mktemp)"
trap 'rm -f "$case_table" "$compile_output"' EXIT

typst query --root . tests/negative.typ '<negative-cases>' --field value --one \
  | python3 -c 'import json,sys
for case in json.load(sys.stdin):
    print(case["name"] + "\t" + case["expect"])' > "$case_table" || {
  echo "could not read the case list from tests/negative.typ" >&2
  exit 1
}

case_count="$(wc -l < "$case_table" | tr -d ' ')"
requested_case="${1:-}"

passed=0
failed=0

run_case() {
  local case_index="$1"
  local case_line case_name expected_text
  case_line="$(sed -n "$((case_index + 1))p" "$case_table")"
  case_name="${case_line%%$'\t'*}"
  expected_text="${case_line#*$'\t'}"

  if typst compile --root . --input "case=$case_index" tests/negative.typ \
      --format pdf - > /dev/null 2> "$compile_output"; then
    printf 'FAIL  %3d  %s\n' "$case_index" "$case_name"
    printf '        compiled successfully; expected a diagnostic mentioning %s\n' "\"$expected_text\""
    failed=$((failed + 1))
    return
  fi

  if ! grep -qF -- "$expected_text" "$compile_output"; then
    printf 'FAIL  %3d  %s\n' "$case_index" "$case_name"
    printf '        diagnostic did not mention %s\n' "\"$expected_text\""
    sed -n '1,3p' "$compile_output" | sed 's/^/        | /'
    failed=$((failed + 1))
    return
  fi

  printf 'ok    %3d  %s\n' "$case_index" "$case_name"
  passed=$((passed + 1))
}

if [ -n "$requested_case" ]; then
  run_case "$requested_case"
else
  for case_index in $(seq 0 $((case_count - 1))); do
    run_case "$case_index"
  done
fi

echo
echo "negative diagnostics: $passed passed, $failed failed"
[ "$failed" -eq 0 ]
