#!/bin/bash
# test_exam_l3_epur_str.sh — hash verification
# Usage: bash test_exam_l3_epur_str.sh [source_dir]
set -e

EXERCISE_ID="exam_l3_epur_str"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 3: Remove extra spaces/tabs)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/epur_str.c" ]; then
    echo "FAILED: File 'epur_str.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/epur_str.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in epur_str.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/epur_str.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/epur_str.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/epur_str.c"
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

# --- Test 1: Basic multiple spaces ---
run_test 1 "Multiple spaces" "hello world" "  hello   world  "

# --- Test 2: Single word ---
run_test 2 "Single word" "hello" "hello"

# --- Test 3: Leading/trailing spaces ---
run_test 3 "Leading/trailing" "hello world" "   hello world   "

# --- Test 4: Tabs and spaces mixed ---
run_test 4 "Tabs and spaces" "hello world" "$(printf '  \t hello  \t  world\t ')"

# --- Test 5: Only spaces ---
run_test 5 "Only spaces" "" "     "

# --- Test 6: Empty string ---
run_test 6 "Empty string" "" ""

# --- Test 7: No arguments ---
run_test_noargs 7 "No arguments" ""

# --- Test 8: No extra spaces ---
run_test 8 "Already clean" "one two three" "one two three"

# --- Test 9: Single char ---
run_test 9 "Single char" "a" " a "

# --- Test 10: Multiple words many spaces ---
run_test 10 "Many words" "a b c d" "  a    b    c    d  "

# --- Test 11: Tab only between words ---
run_test 11 "Tab between words" "hello world" "$(printf 'hello\tworld')"

# --- Test 12: Multiple tabs ---
run_test 12 "Multiple tabs" "abc def" "$(printf '\t\tabc\t\t\tdef\t\t')"

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
