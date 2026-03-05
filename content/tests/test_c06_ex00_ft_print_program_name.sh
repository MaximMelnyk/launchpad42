#!/bin/bash
# test_c06_ex00_ft_print_program_name.sh — hash verification
# Usage: bash test_c06_ex00_ft_print_program_name.sh [source_dir]
set -e

EXERCISE_ID="c06_ex00_ft_print_program_name"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C06 ex00: ft_print_program_name — print argv[0])"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_print_program_name.c" ]; then
    echo "FAILED: File 'ft_print_program_name.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_print_program_name.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_print_program_name.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_print_program_name.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_print_program_name.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_print_program_name.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Default program name ---
echo "Test 1: Default program name..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 "${SRC_DIR}/ft_print_program_name.c"

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1="/tmp/${EXERCISE_ID}_test1"

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Default program name"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1
    exit 1
fi
echo "  PASS"

# --- Test 2: Renamed binary ---
echo "Test 2: Renamed binary..."
cp /tmp/${EXERCISE_ID}_test1 /tmp/my_cool_program
RESULT2=$(/tmp/my_cool_program)
EXPECTED2="/tmp/my_cool_program"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Renamed binary"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/my_cool_program
    exit 1
fi
echo "  PASS"
rm -f /tmp/my_cool_program

# --- Test 3: With extra arguments (should still only print argv[0]) ---
echo "Test 3: Extra arguments ignored..."
RESULT3=$(/tmp/${EXERCISE_ID}_test1 hello world 42)
EXPECTED3="/tmp/${EXERCISE_ID}_test1"

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Should only print argv[0] even with extra args"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test1
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
