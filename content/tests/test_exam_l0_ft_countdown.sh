#!/bin/bash
# test_exam_l0_ft_countdown.sh — hash verification
# Usage: bash test_exam_l0_ft_countdown.sh [source_dir]
set -e

EXERCISE_ID="exam_l0_ft_countdown"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 0: Print 9876543210 + newline)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_countdown.c" ]; then
    echo "FAILED: File 'ft_countdown.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/ft_countdown.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_countdown.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_countdown.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_countdown.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/ft_countdown.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

# --- Test 1: Output check ---
echo "Test 1: Output '9876543210'..."
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="9876543210"

if [ "$RESULT" != "$EXPECTED" ]; then
    echo "FAILED: Output mismatch"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$RESULT'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 2: Exact byte count (10 digits + newline = 11 bytes) ---
echo "Test 2: Exact byte count..."
BYTE_COUNT=$(/tmp/${EXERCISE_ID}_test | wc -c)
if [ "$BYTE_COUNT" -ne 11 ]; then
    echo "FAILED: Expected 11 bytes (9876543210 + newline), got $BYTE_COUNT"
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
