#!/bin/bash
# test_exam_l2_inter.sh — hash verification
# Usage: bash test_exam_l2_inter.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_inter"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Print intersection of two strings)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/inter.c" ]; then
    echo "FAILED: File 'inter.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/inter.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in inter.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/inter.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/inter.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/inter.c"
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

# --- Test 1: Basic intersection ---
run_test 1 "'padinton' 'pansen'" "pan" "padinton" "pansen"

# --- Test 2: Spaces in strings ---
run_test 2 "'los an' 'las ans'" "ls an" "los an" "las ans"

# --- Test 3: Duplicates in first ---
run_test 3 "'aaa' 'a'" "a" "aaa" "a"

# --- Test 4: No intersection ---
run_test 4 "'abc' 'def'" "" "abc" "def"

# --- Test 5: No arguments ---
run_test_noargs 5 "No arguments" ""

# --- Test 6: Empty first string ---
run_test 6 "Empty first string" "" "" "hello"

# --- Test 7: Empty second string ---
run_test 7 "Empty second string" "" "hello" ""

# --- Test 8: Identical strings ---
run_test 8 "Identical 'abc' 'abc'" "abc" "abc" "abc"

# --- Test 9: Single arg ---
echo "Test 9: Single arg..."
RESULT=$(/tmp/${EXERCISE_ID}_test "hello" 2>/dev/null || true)
if [ "$RESULT" == "" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '', Got '${RESULT}'"
    ((FAIL++))
fi

# --- Test 10: Order preserved from s1 ---
run_test 10 "'dcba' 'abcd'" "dcba" "dcba" "abcd"

# --- Test 11: Mixed chars with digits ---
run_test 11 "'a1b2c3' '321'" "123" "a1b2c3" "321"

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
