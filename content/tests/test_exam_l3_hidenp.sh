#!/bin/bash
# test_exam_l3_hidenp.sh — hash verification
# Usage: bash test_exam_l3_hidenp.sh [source_dir]
set -e

EXERCISE_ID="exam_l3_hidenp"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 3: Hidden string check)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/hidenp.c" ]; then
    echo "FAILED: File 'hidenp.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/hidenp.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in hidenp.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/hidenp.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/hidenp.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/hidenp.c"
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

# --- Test 1: Basic hidden ---
run_test 1 "'abc' in 'azbycx'" "1" "abc" "azbycx"

# --- Test 2: Not hidden (wrong order) ---
run_test 2 "'abc' in 'cab'" "0" "abc" "cab"

# --- Test 3: Long hidden ---
run_test 3 "'fgex' in 'face your fear, gin'" "1" "fgex" "face your fear, gin"

# --- Test 4: Empty s1 hidden in anything ---
run_test 4 "'' in 'anything'" "1" "" "anything"

# --- Test 5: Non-empty in empty ---
run_test 5 "'abc' in ''" "0" "abc" ""

# --- Test 6: Both empty ---
run_test 6 "'' in ''" "1" "" ""

# --- Test 7: No arguments ---
run_test_noargs 7 "No arguments" ""

# --- Test 8: Single arg ---
echo "Test 8: Single arg..."
RESULT=$(/tmp/${EXERCISE_ID}_test "hello" 2>/dev/null || true)
if [ "$RESULT" == "" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '', Got '${RESULT}'"
    ((FAIL++))
fi

# --- Test 9: Identical strings ---
run_test 9 "'abc' in 'abc'" "1" "abc" "abc"

# --- Test 10: Single char hidden ---
run_test 10 "'a' in 'xyz a'" "1" "a" "xyz a"

# --- Test 11: Single char not found ---
run_test 11 "'z' in 'abc'" "0" "z" "abc"

# --- Test 12: s1 longer than s2 ---
run_test 12 "'abcdef' in 'abc'" "0" "abcdef" "abc"

# --- Test 13: Repeated chars ---
run_test 13 "'aaa' in 'abababab'" "0" "aaa" "abababab"

# --- Test 14: Repeated chars found ---
run_test 14 "'aa' in 'aXa'" "1" "aa" "aXa"

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
