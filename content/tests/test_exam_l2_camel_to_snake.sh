#!/bin/bash
# test_exam_l2_camel_to_snake.sh — hash verification
# Usage: bash test_exam_l2_camel_to_snake.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_camel_to_snake"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Convert camelCase to snake_case)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/camel_to_snake.c" ]; then
    echo "FAILED: File 'camel_to_snake.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/camel_to_snake.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in camel_to_snake.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/camel_to_snake.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/camel_to_snake.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/camel_to_snake.c"
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

# --- Test 1: Simple camelCase ---
run_test 1 "helloWorld" "hello_world" "helloWorld"

# --- Test 2: Multiple uppercase ---
run_test 2 "getString" "get_string" "getString"

# --- Test 3: Leading uppercase ---
run_test 3 "CamelCase" "_camel_case" "CamelCase"

# --- Test 4: No uppercase ---
run_test 4 "already_snake" "already_snake" "already_snake"

# --- Test 5: All lowercase ---
run_test 5 "hello" "hello" "hello"

# --- Test 6: No arguments ---
run_test_noargs 6 "No arguments" ""

# --- Test 7: Empty string ---
run_test 7 "Empty string" "" ""

# --- Test 8: Multiple consecutive words ---
run_test 8 "getNextLineFromFile" "get_next_line_from_file" "getNextLineFromFile"

# --- Test 9: Single char lowercase ---
run_test 9 "Single char 'a'" "a" "a"

# --- Test 10: Single char uppercase ---
run_test 10 "Single char 'A'" "_a" "A"

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
echo "Code: $HASH"
exit 0
