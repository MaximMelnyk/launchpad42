#!/bin/bash
# test_exam_l2_do_op.sh — hash verification
# Usage: bash test_exam_l2_do_op.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_do_op"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Calculator with argv)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/do_op.c" ]; then
    echo "FAILED: File 'do_op.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/do_op.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in do_op.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/do_op.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/do_op.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/do_op.c"
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

# --- Test 1: Addition ---
run_test 1 "42 + 21" "63" "42" "+" "21"

# --- Test 2: Subtraction ---
run_test 2 "42 - 21" "21" "42" "-" "21"

# --- Test 3: Multiplication ---
run_test 3 "42 * 2" "84" "42" "*" "2"

# --- Test 4: Division ---
run_test 4 "42 / 5" "8" "42" "/" "5"

# --- Test 5: Modulo ---
run_test 5 "42 % 5" "2" "42" "%" "5"

# --- Test 6: Division by zero ---
run_test 6 "42 / 0" "" "42" "/" "0"

# --- Test 7: Modulo by zero ---
run_test 7 "42 % 0" "" "42" "%" "0"

# --- Test 8: No arguments ---
run_test_noargs 8 "No arguments" ""

# --- Test 9: Negative numbers ---
run_test 9 "-42 + 42" "0" "-42" "+" "42"

# --- Test 10: Negative result ---
run_test 10 "5 - 10" "-5" "5" "-" "10"

# --- Test 11: Zero operations ---
run_test 11 "0 + 0" "0" "0" "+" "0"

# --- Test 12: Large multiplication ---
run_test 12 "1000 * 1000" "1000000" "1000" "*" "1000"

# --- Test 13: Exact division ---
run_test 13 "100 / 10" "10" "100" "/" "10"

# --- Test 14: Negative division ---
run_test 14 "-42 / 5" "-8" "-42" "/" "5"

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
