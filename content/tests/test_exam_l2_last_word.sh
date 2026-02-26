#!/bin/bash
# test_exam_l2_last_word.sh — hash verification
# Usage: bash test_exam_l2_last_word.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_last_word"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Print last word of argv[1])"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/last_word.c" ]; then
    echo "FAILED: File 'last_word.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/last_word.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in last_word.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/last_word.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/last_word.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/last_word.c"
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

# --- Test 1: Normal sentence ---
run_test 1 "'hello world'" "world" "hello world"

# --- Test 2: Trailing spaces ---
run_test 2 "'  piscine   42  '" "42" "  piscine   42  "

# --- Test 3: Single word ---
run_test 3 "'single'" "single" "single"

# --- Test 4: Tabs ---
run_test 4 "Tabs mixed" "end" "$(printf '\t  end\t')"

# --- Test 5: No arguments ---
run_test_noargs 5 "No arguments" ""

# --- Test 6: Only spaces ---
run_test 6 "Only spaces" "" "     "

# --- Test 7: Empty string ---
run_test 7 "Empty string" "" ""

# --- Test 8: Multiple trailing whitespace ---
run_test 8 "Multiple trailing" "last" "first middle last   "

# --- Test 9: Tab-separated ---
run_test 9 "Tab separated" "world" "$(printf 'hello\tworld')"

# --- Test 10: Single character ---
run_test 10 "Single char" "a" "a"

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
