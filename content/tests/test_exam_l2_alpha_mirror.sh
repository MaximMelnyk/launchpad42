#!/bin/bash
# test_exam_l2_alpha_mirror.sh — hash verification
# Usage: bash test_exam_l2_alpha_mirror.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_alpha_mirror"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Replace each letter with its mirror in alphabet)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/alpha_mirror.c" ]; then
    echo "FAILED: File 'alpha_mirror.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/alpha_mirror.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in alpha_mirror.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/alpha_mirror.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/alpha_mirror.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/alpha_mirror.c"
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

# --- Test 1: Simple lowercase ---
run_test 1 "Simple lowercase 'abc'" "zyx" "abc"

# --- Test 2: Full lowercase alphabet ---
run_test 2 "Full lowercase alphabet" "zyxwvutsrqponmlkjihgfedcba" "abcdefghijklmnopqrstuvwxyz"

# --- Test 3: Mixed case with spaces ---
run_test 3 "Mixed 'My Music'" "Nb Nfhrx" "My Music"

# --- Test 4: Uppercase with digits ---
run_test 4 "Uppercase + digits 'AkjhZ 5. '" "ZpqsA 5. " "AkjhZ 5. "

# --- Test 5: No arguments ---
run_test_noargs 5 "No arguments" ""

# --- Test 6: Empty string ---
run_test 6 "Empty string" "" ""

# --- Test 7: Only non-alpha ---
run_test 7 "Only non-alpha '123 !@#'" "123 !@#" "123 !@#"

# --- Test 8: Single char 'a' ---
run_test 8 "Single char 'a'" "z" "a"

# --- Test 9: Single char 'z' ---
run_test 9 "Single char 'z'" "a" "z"

# --- Test 10: Single char 'Z' ---
run_test 10 "Single char 'Z'" "A" "Z"

# --- Test 11: Uppercase alphabet ---
run_test 11 "Full uppercase alphabet" "ZYXWVUTSRQPONMLKJIHGFEDCBA" "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

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
