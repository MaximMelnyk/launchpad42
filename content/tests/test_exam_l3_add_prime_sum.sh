#!/bin/bash
# test_exam_l3_add_prime_sum.sh — hash verification
# Usage: bash test_exam_l3_add_prime_sum.sh [source_dir]
set -e

EXERCISE_ID="exam_l3_add_prime_sum"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 3: Sum of all primes <= N)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/add_prime_sum.c" ]; then
    echo "FAILED: File 'add_prime_sum.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b|\bmalloc\b' "${SRC_DIR}/add_prime_sum.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in add_prime_sum.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/add_prime_sum.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/add_prime_sum.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/add_prime_sum.c"
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

# --- Test 1: N=5 (2+3+5=10) ---
run_test 1 "N=5" "10" "5"

# --- Test 2: N=2 ---
run_test 2 "N=2" "2" "2"

# --- Test 3: N=1 (no primes) ---
run_test 3 "N=1" "0" "1"

# --- Test 4: N=0 ---
run_test 4 "N=0" "0" "0"

# --- Test 5: N=100 ---
run_test 5 "N=100" "1060" "100"

# --- Test 6: N=10 (2+3+5+7=17) ---
run_test 6 "N=10" "17" "10"

# --- Test 7: N=3 (2+3=5) ---
run_test 7 "N=3" "5" "3"

# --- Test 8: No arguments ---
run_test_noargs 8 "No arguments" "0"

# --- Test 9: N=50 ---
run_test 9 "N=50" "328" "50"

# --- Test 10: N=7 (2+3+5+7=17) ---
run_test 10 "N=7" "17" "7"

# --- Test 11: N=11 (2+3+5+7+11=28) ---
run_test 11 "N=11" "28" "11"

# --- Test 12: N=20 (2+3+5+7+11+13+17+19=77) ---
run_test 12 "N=20" "77" "20"

# --- Test 13: Negative number ---
run_test 13 "N=-5" "0" "-5"

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
