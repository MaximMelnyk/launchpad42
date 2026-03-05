#!/bin/bash
# test_exam_l3_paramsum.sh — hash verification
# Usage: bash test_exam_l3_paramsum.sh [source_dir]
set -e

EXERCISE_ID="exam_l3_paramsum"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 3: Print parameter count)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/paramsum.c" ]; then
    echo "FAILED: File 'paramsum.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/paramsum.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in paramsum.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/paramsum.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/paramsum.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/paramsum.c"
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

# --- Test 1: No arguments ---
run_test_noargs 1 "No arguments" "0"

# --- Test 2: One argument ---
run_test 2 "One argument" "1" "hello"

# --- Test 3: Two arguments ---
run_test 3 "Two arguments" "2" "hello" "world"

# --- Test 4: Three arguments ---
run_test 4 "Three arguments" "3" "hello world" "foo" "bar"

# --- Test 5: Ten arguments ---
run_test 5 "Ten arguments" "10" "a" "b" "c" "d" "e" "f" "g" "h" "i" "j"

# --- Test 6: Single char ---
run_test 6 "Single char arg" "1" "x"

# --- Test 7: Five arguments ---
run_test 7 "Five arguments" "5" "1" "2" "3" "4" "5"

# --- Test 8: Argument with spaces (quoted) ---
run_test 8 "Quoted argument with spaces" "1" "hello world foo"

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
