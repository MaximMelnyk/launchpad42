#!/bin/bash
# test_exam_l3_rstr_capitalizer.sh — hash verification
# Usage: bash test_exam_l3_rstr_capitalizer.sh [source_dir]
set -e

EXERCISE_ID="exam_l3_rstr_capitalizer"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 3: Capitalize last letter of each word)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/rstr_capitalizer.c" ]; then
    echo "FAILED: File 'rstr_capitalizer.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/rstr_capitalizer.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in rstr_capitalizer.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/rstr_capitalizer.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/rstr_capitalizer.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/rstr_capitalizer.c"
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

# --- Test 1: Basic two words ---
run_test 1 "hello world" "hellO worlD" "hello world"

# --- Test 2: All uppercase input ---
run_test 2 "HELLO WORLD" "hellO worlD" "HELLO WORLD"

# --- Test 3: Multiple args ---
echo "Test 3: Multiple args (2 lines)..."
EXPECTED="$(printf 'hellO\nworlD')"
RESULT=$(/tmp/${EXERCISE_ID}_test "hello" "world" 2>/dev/null || true)
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '${EXPECTED}', Got '${RESULT}'"
    ((FAIL++))
fi

# --- Test 4: Single char words ---
run_test 4 "Single char words 'a b'" "A B" "a  b"

# --- Test 5: No arguments ---
run_test_noargs 5 "No arguments" ""

# --- Test 6: Mixed case ---
run_test 6 "hElLo WoRlD" "hellO worlD" "hElLo WoRlD"

# --- Test 7: Single word ---
run_test 7 "Single word 'test'" "tesT" "test"

# --- Test 8: Trailing spaces preserved ---
run_test 8 "Words with double spaces" "hellO  worlD" "hello  world"

# --- Test 9: Tab separator ---
run_test 9 "Tab separator" "$(printf 'hellO\tworlD')" "$(printf 'hello\tworld')"

# --- Test 10: Numbers in string (not alpha) ---
run_test 10 "abc123 def" "abc123 deF" "abc123 def"

# --- Test 11: Single char ---
run_test 11 "Single char 'a'" "A" "a"

# --- Test 12: Empty string ---
run_test 12 "Empty string" "" ""

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
