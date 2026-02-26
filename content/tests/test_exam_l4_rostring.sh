#!/bin/bash
# test_exam_l4_rostring.sh — hash verification
# Usage: bash test_exam_l4_rostring.sh [source_dir]
set -e

EXERCISE_ID="exam_l4_rostring"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 4: rostring — rotate first word to end)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/rostring.c" ]; then
    echo "FAILED: File 'rostring.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b|\bmalloc\b' "${SRC_DIR}/rostring.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in rostring.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/rostring.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/rostring.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/rostring.c"
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

# --- Test 1: basic rotation ---
run_test 1 "'abc   def    ghi'" "def ghi abc" "abc   def    ghi"

# --- Test 2: single word ---
run_test 2 "'hello'" "hello" "hello"

# --- Test 3: leading/trailing spaces ---
run_test 3 "'   hello   world   42   '" "world 42 hello" "   hello   world   42   "

# --- Test 4: empty string ---
run_test 4 "Empty string" "" ""

# --- Test 5: no arguments ---
run_test_noargs 5 "No arguments" ""

# --- Test 6: two words ---
run_test 6 "'first second'" "second first" "first second"

# --- Test 7: tabs as separators ---
run_test 7 "Tabs: 'abc\tdef\tghi'" "def ghi abc" "abc	def	ghi"

# --- Test 8: mixed spaces and tabs ---
run_test 8 "Mixed whitespace" "B C A" "  A 	 B 	 C  "

# --- Test 9: only spaces (no words) ---
run_test 9 "Only spaces" "" "     "

# --- Test 10: many words ---
run_test 10 "'one two three four five'" "two three four five one" "one two three four five"

# --- Test 11: single char word ---
run_test 11 "'a b c'" "b c a" "a b c"

# --- Test 12: extra args ignored ---
echo "Test 12: Extra args ignored..."
RESULT=$(/tmp/${EXERCISE_ID}_test "hello world" "extra" 2>/dev/null || true)
if [ "$RESULT" == "world hello" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected 'world hello', Got '${RESULT}'"
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
