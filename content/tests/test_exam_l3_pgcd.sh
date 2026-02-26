#!/bin/bash
# test_exam_l3_pgcd.sh — hash verification
# Usage: bash test_exam_l3_pgcd.sh [source_dir]
set -e

EXERCISE_ID="exam_l3_pgcd"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 3: Greatest Common Divisor)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/pgcd.c" ]; then
    echo "FAILED: File 'pgcd.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/pgcd.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in pgcd.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/pgcd.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/pgcd.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/pgcd.c"
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

# --- Test 1: gcd(42, 10) = 2 ---
run_test 1 "gcd(42, 10)" "2" "42" "10"

# --- Test 2: gcd(14, 77) = 7 ---
run_test 2 "gcd(14, 77)" "7" "14" "77"

# --- Test 3: gcd(100, 75) = 25 ---
run_test 3 "gcd(100, 75)" "25" "100" "75"

# --- Test 4: gcd(17, 3) = 1 (coprime) ---
run_test 4 "gcd(17, 3) coprime" "1" "17" "3"

# --- Test 5: No arguments ---
run_test_noargs 5 "No arguments" ""

# --- Test 6: One argument ---
echo "Test 6: One argument..."
RESULT=$(/tmp/${EXERCISE_ID}_test "42" 2>/dev/null || true)
if [ "$RESULT" == "" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '', Got '${RESULT}'"
    ((FAIL++))
fi

# --- Test 7: gcd(12, 18) = 6 ---
run_test 7 "gcd(12, 18)" "6" "12" "18"

# --- Test 8: gcd(7, 7) = 7 ---
run_test 8 "gcd(7, 7) same" "7" "7" "7"

# --- Test 9: gcd(1, 100) = 1 ---
run_test 9 "gcd(1, 100)" "1" "1" "100"

# --- Test 10: gcd(48, 36) = 12 ---
run_test 10 "gcd(48, 36)" "12" "48" "36"

# --- Test 11: gcd(1000000, 500000) = 500000 ---
run_test 11 "gcd(1000000, 500000)" "500000" "1000000" "500000"

# --- Test 12: Three arguments (invalid) ---
echo "Test 12: Three arguments..."
RESULT=$(/tmp/${EXERCISE_ID}_test "42" "10" "5" 2>/dev/null || true)
if [ "$RESULT" == "" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '', Got '${RESULT}'"
    ((FAIL++))
fi

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
