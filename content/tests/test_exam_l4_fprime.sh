#!/bin/bash
# test_exam_l4_fprime.sh — hash verification
# Usage: bash test_exam_l4_fprime.sh [source_dir]
set -e

EXERCISE_ID="exam_l4_fprime"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 4: Prime factorization)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/fprime.c" ]; then
    echo "FAILED: File 'fprime.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/fprime.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in fprime.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/fprime.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/fprime.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/fprime.c"
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

# --- Test 1: No arguments ---
run_test_noargs 1 "No arguments (newline only)" ""

# --- Test 2: Number 1 ---
run_test 2 "fprime 1" "1" "1"

# --- Test 3: Prime number 2 ---
run_test 3 "fprime 2" "2" "2"

# --- Test 4: Prime number 11 ---
run_test 4 "fprime 11" "11" "11"

# --- Test 5: 42 = 2 * 3 * 7 ---
run_test 5 "fprime 42" "2 * 3 * 7" "42"

# --- Test 6: 225 = 3 * 3 * 5 * 5 ---
run_test 6 "fprime 225" "3 * 3 * 5 * 5" "225"

# --- Test 7: Power of 2 (64) ---
run_test 7 "fprime 64" "2 * 2 * 2 * 2 * 2 * 2" "64"

# --- Test 8: Large prime 127 ---
run_test 8 "fprime 127" "127" "127"

# --- Test 9: 100 = 2 * 2 * 5 * 5 ---
run_test 9 "fprime 100" "2 * 2 * 5 * 5" "100"

# --- Test 10: 12 = 2 * 2 * 3 ---
run_test 10 "fprime 12" "2 * 2 * 3" "12"

# --- Test 11: 999 = 3 * 3 * 3 * 37 ---
run_test 11 "fprime 999" "3 * 3 * 3 * 37" "999"

# --- Test 12: 7919 (prime) ---
run_test 12 "fprime 7919 (prime)" "7919" "7919"

# --- Test 13: 2310 = 2 * 3 * 5 * 7 * 11 ---
run_test 13 "fprime 2310" "2 * 3 * 5 * 7 * 11" "2310"

# --- Test 14: 4 = 2 * 2 ---
run_test 14 "fprime 4" "2 * 2" "4"

# --- Test 15: 17 (prime) ---
run_test 15 "fprime 17" "17" "17"

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
