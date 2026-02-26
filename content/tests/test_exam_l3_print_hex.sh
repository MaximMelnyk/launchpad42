#!/bin/bash
# test_exam_l3_print_hex.sh — hash verification
# Usage: bash test_exam_l3_print_hex.sh [source_dir]
set -e

EXERCISE_ID="exam_l3_print_hex"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 3: Print number as hexadecimal)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/print_hex.c" ]; then
    echo "FAILED: File 'print_hex.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/print_hex.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in print_hex.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/print_hex.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/print_hex.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/print_hex.c"
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

# --- Test 1: 42 -> 2a ---
run_test 1 "42 -> 2a" "2a" "42"

# --- Test 2: 0 -> 0 ---
run_test 2 "0 -> 0" "0" "0"

# --- Test 3: 255 -> ff ---
run_test 3 "255 -> ff" "ff" "255"

# --- Test 4: 16 -> 10 ---
run_test 4 "16 -> 10" "10" "16"

# --- Test 5: 1 -> 1 ---
run_test 5 "1 -> 1" "1" "1"

# --- Test 6: 10 -> a ---
run_test 6 "10 -> a" "a" "10"

# --- Test 7: 256 -> 100 ---
run_test 7 "256 -> 100" "100" "256"

# --- Test 8: No arguments ---
run_test_noargs 8 "No arguments" ""

# --- Test 9: 15 -> f ---
run_test 9 "15 -> f" "f" "15"

# --- Test 10: 1000 -> 3e8 ---
run_test 10 "1000 -> 3e8" "3e8" "1000"

# --- Test 11: 65535 -> ffff ---
run_test 11 "65535 -> ffff" "ffff" "65535"

# --- Test 12: 100 -> 64 ---
run_test 12 "100 -> 64" "64" "100"

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
