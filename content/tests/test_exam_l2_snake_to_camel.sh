#!/bin/bash
# test_exam_l2_snake_to_camel.sh — hash verification
# Usage: bash test_exam_l2_snake_to_camel.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_snake_to_camel"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Convert snake_case to lowerCamelCase)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/snake_to_camel.c" ]; then
    echo "FAILED: File 'snake_to_camel.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/snake_to_camel.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in snake_to_camel.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/snake_to_camel.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/snake_to_camel.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/snake_to_camel.c"
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

# --- Test 1: Simple snake_case ---
run_test 1 "hello_world" "helloWorld" "hello_world"

# --- Test 2: Multiple underscores ---
run_test 2 "get_next_line" "getNextLine" "get_next_line"

# --- Test 3: No underscores ---
run_test 3 "alreadycamel" "alreadycamel" "alreadycamel"

# --- Test 4: No arguments ---
run_test_noargs 4 "No arguments" ""

# --- Test 5: Empty string ---
run_test 5 "Empty string" "" ""

# --- Test 6: Single word ---
run_test 6 "Single word 'hello'" "hello" "hello"

# --- Test 7: Three words ---
run_test 7 "ft_is_power_2" "ftIsPower2" "ft_is_power_2"

# --- Test 8: Underscore at start ---
run_test 8 "_hello" "Hello" "_hello"

# --- Test 9: Long chain ---
run_test 9 "a_b_c_d_e" "aBCDE" "a_b_c_d_e"

# --- Test 10: Single char ---
run_test 10 "Single char 'a'" "a" "a"

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
