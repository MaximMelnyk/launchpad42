#!/bin/bash
# test_exam_l3_tab_mult.sh — hash verification
# Usage: bash test_exam_l3_tab_mult.sh [source_dir]
set -e

EXERCISE_ID="exam_l3_tab_mult"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 3: Multiplication table)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/tab_mult.c" ]; then
    echo "FAILED: File 'tab_mult.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/tab_mult.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in tab_mult.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/tab_mult.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/tab_mult.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/tab_mult.c"
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

# --- Test 1: tab_mult 3 ---
EXPECTED_3="$(printf '1 x 3 = 3\n2 x 3 = 6\n3 x 3 = 9\n4 x 3 = 12\n5 x 3 = 15\n6 x 3 = 18\n7 x 3 = 21\n8 x 3 = 24\n9 x 3 = 27')"
run_test 1 "tab_mult 3" "$EXPECTED_3" "3"

# --- Test 2: tab_mult 1 ---
EXPECTED_1="$(printf '1 x 1 = 1\n2 x 1 = 2\n3 x 1 = 3\n4 x 1 = 4\n5 x 1 = 5\n6 x 1 = 6\n7 x 1 = 7\n8 x 1 = 8\n9 x 1 = 9')"
run_test 2 "tab_mult 1" "$EXPECTED_1" "1"

# --- Test 3: tab_mult 9 ---
EXPECTED_9="$(printf '1 x 9 = 9\n2 x 9 = 18\n3 x 9 = 27\n4 x 9 = 36\n5 x 9 = 45\n6 x 9 = 54\n7 x 9 = 63\n8 x 9 = 72\n9 x 9 = 81')"
run_test 3 "tab_mult 9" "$EXPECTED_9" "9"

# --- Test 4: No arguments ---
run_test_noargs 4 "No arguments" ""

# --- Test 5: tab_mult 0 ---
EXPECTED_0="$(printf '1 x 0 = 0\n2 x 0 = 0\n3 x 0 = 0\n4 x 0 = 0\n5 x 0 = 0\n6 x 0 = 0\n7 x 0 = 0\n8 x 0 = 0\n9 x 0 = 0')"
run_test 5 "tab_mult 0" "$EXPECTED_0" "0"

# --- Test 6: tab_mult 10 ---
EXPECTED_10="$(printf '1 x 10 = 10\n2 x 10 = 20\n3 x 10 = 30\n4 x 10 = 40\n5 x 10 = 50\n6 x 10 = 60\n7 x 10 = 70\n8 x 10 = 80\n9 x 10 = 90')"
run_test 6 "tab_mult 10" "$EXPECTED_10" "10"

# --- Test 7: tab_mult 5 ---
EXPECTED_5="$(printf '1 x 5 = 5\n2 x 5 = 10\n3 x 5 = 15\n4 x 5 = 20\n5 x 5 = 25\n6 x 5 = 30\n7 x 5 = 35\n8 x 5 = 40\n9 x 5 = 45')"
run_test 7 "tab_mult 5" "$EXPECTED_5" "5"

# --- Test 8: tab_mult -3 (negative) ---
EXPECTED_NEG="$(printf '1 x -3 = -3\n2 x -3 = -6\n3 x -3 = -9\n4 x -3 = -12\n5 x -3 = -15\n6 x -3 = -18\n7 x -3 = -21\n8 x -3 = -24\n9 x -3 = -27')"
run_test 8 "tab_mult -3" "$EXPECTED_NEG" "-3"

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
