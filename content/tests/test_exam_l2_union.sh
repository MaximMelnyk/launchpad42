#!/bin/bash
# test_exam_l2_union.sh — hash verification
# Usage: bash test_exam_l2_union.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_union"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Print union of two strings, no duplicates)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/union.c" ]; then
    echo "FAILED: File 'union.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/union.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in union.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/union.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/union.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/union.c"
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

# --- Test 1: Basic union ---
run_test 1 "'zpadinton' 'pansen'" "zpadintons" "zpadinton" "pansen"

# --- Test 2: All duplicates ---
run_test 2 "'aaa' 'a'" "a" "aaa" "a"

# --- Test 3: No overlap ---
run_test 3 "'abc' 'def'" "abcdef" "abc" "def"

# --- Test 4: No arguments ---
run_test_noargs 4 "No arguments" ""

# --- Test 5: Empty first string ---
run_test 5 "Empty first" "hello" "" "hello"

# --- Test 6: Empty second string ---
run_test 6 "Empty second" "hello" "hello" ""

# --- Test 7: Both empty ---
run_test 7 "Both empty" "" "" ""

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

# --- Test 10: Numbers and letters ---
run_test 10 "'abc123' 'def456'" "abc123def456" "abc123" "def456"

# --- Test 11: Repeated chars across both ---
run_test 11 "'aabb' 'bbcc'" "abbc" "aabb" "bbcc"

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
