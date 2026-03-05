#!/bin/bash
# test_exam_l3_expand_str.sh — hash verification
# Usage: bash test_exam_l3_expand_str.sh [source_dir]
set -e

EXERCISE_ID="exam_l3_expand_str"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 3: Separate words with exactly 3 spaces)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/expand_str.c" ]; then
    echo "FAILED: File 'expand_str.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/expand_str.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in expand_str.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/expand_str.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/expand_str.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/expand_str.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

PASS=0
FAIL=0

run_test() {
    local test_num="$1"
    local desc="$2"
    local expected="$3"
    shift 3
    echo "Test ${test_num}: ${desc}..."
    RESULT=$(/tmp/${EXERCISE_ID}_test "$@" 2>/dev/null || true)
    if [ "$RESULT" == "$expected" ]; then
        echo "  PASS"
        ((PASS++))
    else
        echo "  FAIL: Expected '${expected}', Got '${RESULT}'"
        ((FAIL++))
    fi
}

run_test_noargs() {
    local test_num="$1"
    local desc="$2"
    local expected="$3"
    echo "Test ${test_num}: ${desc}..."
    RESULT=$(/tmp/${EXERCISE_ID}_test 2>/dev/null || true)
    if [ "$RESULT" == "$expected" ]; then
        echo "  PASS"
        ((PASS++))
    else
        echo "  FAIL: Expected '${expected}', Got '${RESULT}'"
        ((FAIL++))
    fi
}

# --- Test 1: Basic two words ---
run_test 1 "Two words" "hello   world" "hello   world"

# --- Test 2: Leading/trailing spaces removed ---
run_test 2 "Leading/trailing" "hello   world   !" "  hello   world   !"

# --- Test 3: Tabs between words ---
run_test 3 "Tabs" "a   b   c" "$(printf 'a\tb\tc')"

# --- Test 4: No arguments ---
run_test_noargs 4 "No arguments" ""

# --- Test 5: Single word ---
run_test 5 "Single word" "hello" "  hello  "

# --- Test 6: Empty string ---
run_test 6 "Empty string" "" ""

# --- Test 7: Multiple spaces become 3 ---
run_test 7 "Many spaces" "one   two   three" "one      two      three"

# --- Test 8: Only spaces ---
run_test 8 "Only spaces" "" "     "

# --- Test 9: Single char words ---
run_test 9 "Single chars" "a   b   c   d" " a  b  c  d "

# --- Test 10: Mixed tabs and spaces ---
run_test 10 "Mixed whitespace" "hello   world   foo" "$(printf '  hello \t world \t foo  ')"

rm -f /tmp/${EXERCISE_ID}_test

if [ $FAIL -ne 0 ]; then
    echo ""
    echo "TESTS FAILED: $FAIL failed, $PASS passed"
    exit 1
fi

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
