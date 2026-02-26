#!/bin/bash
# test_exam_l2_wdmatch.sh — hash verification
# Usage: bash test_exam_l2_wdmatch.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_wdmatch"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Check if chars of s1 appear in s2 in order)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/wdmatch.c" ]; then
    echo "FAILED: File 'wdmatch.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/wdmatch.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in wdmatch.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/wdmatch.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/wdmatch.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/wdmatch.c"
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

# --- Test 1: Match found ---
run_test 1 "'faya' in long string" "faya" "faya" "fgvfrber ymberEde dings ansen"

# --- Test 2: No match (missing 'a' at right position) ---
run_test 2 "'faya' not found" "" "faya" "fgvfrber ymberEdeDings ansen"

# --- Test 3: Long match with spaces ---
run_test 3 "'quarante deux' in string" "quarante deux" "quarante deux" "qua l eta i nsma nte deux"

# --- Test 4: No common chars ---
run_test 4 "'abc' vs 'def'" "" "abc" "def"

# --- Test 5: No arguments ---
run_test_noargs 5 "No arguments" ""

# --- Test 6: Single arg ---
echo "Test 6: Single arg..."
RESULT=$(/tmp/${EXERCISE_ID}_test "hello" 2>/dev/null || true)
if [ "$RESULT" == "" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '', Got '${RESULT}'"
    ((FAIL++))
fi

# --- Test 7: Empty first string ---
run_test 7 "Empty first string" "" "" "hello"

# --- Test 8: Identical strings ---
run_test 8 "Identical strings" "abc" "abc" "abc"

# --- Test 9: Single char match ---
run_test 9 "Single char match" "a" "a" "bbbabb"

# --- Test 10: Single char no match ---
run_test 10 "Single char no match" "" "a" "bbb"

# --- Test 11: Order matters ---
run_test 11 "'ba' in 'ab' (wrong order)" "" "ba" "ab"

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
