#!/bin/bash
# test_exam_l0_aff_a.sh — hash verification
# Usage: bash test_exam_l0_aff_a.sh [source_dir]
set -e

EXERCISE_ID="exam_l0_aff_a"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 0: Print 'a' + newline)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/aff_a.c" ]; then
    echo "FAILED: File 'aff_a.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/aff_a.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in aff_a.c (printf/scanf/puts/putchar)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/aff_a.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in aff_a.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/aff_a.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Output is 'a\n' ---
echo "Test 1: Output 'a' + newline..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/aff_a.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="a"

if [ "$RESULT" != "$EXPECTED" ]; then
    echo "FAILED: Output mismatch"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$RESULT'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 2: Verify exact bytes (a + \n = 2 bytes) ---
echo "Test 2: Exact byte count..."
BYTE_COUNT=$(/tmp/${EXERCISE_ID}_test | wc -c)
if [ "$BYTE_COUNT" -ne 2 ]; then
    echo "FAILED: Expected 2 bytes (a + newline), got $BYTE_COUNT"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

rm -f /tmp/${EXERCISE_ID}_test

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
