#!/bin/bash
# test_c06_ex01_ft_print_params.sh — hash verification
# Usage: bash test_c06_ex01_ft_print_params.sh [source_dir]
set -e

EXERCISE_ID="c06_ex01_ft_print_params"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C06 ex01: ft_print_params — print all argv params)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_print_params.c" ]; then
    echo "FAILED: File 'ft_print_params.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_print_params.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_print_params.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_print_params.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_print_params.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_print_params.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/ft_print_params.c"

# --- Test 1: Three arguments ---
echo "Test 1: Three arguments..."
RESULT1=$(/tmp/${EXERCISE_ID}_test hello world 42)
EXPECTED1=$(printf 'hello\nworld\n42')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Three arguments"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 2: No arguments ---
echo "Test 2: No arguments..."
RESULT2=$(/tmp/${EXERCISE_ID}_test)
EXPECTED2=""

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: No arguments (should print nothing)"
    echo "Expected: ''"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 3: Single argument ---
echo "Test 3: Single argument..."
RESULT3=$(/tmp/${EXERCISE_ID}_test only)
EXPECTED3="only"

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Single argument"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 4: Arguments with spaces (quoted) ---
echo "Test 4: Quoted argument with spaces..."
RESULT4=$(/tmp/${EXERCISE_ID}_test "hello world" "42 school")
EXPECTED4=$(printf 'hello world\n42 school')

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Quoted arguments"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 5: Many arguments ---
echo "Test 5: Many arguments..."
RESULT5=$(/tmp/${EXERCISE_ID}_test a b c d e f)
EXPECTED5=$(printf 'a\nb\nc\nd\ne\nf')

if [ "$RESULT5" != "$EXPECTED5" ]; then
    echo "FAILED: Many arguments"
    echo "Expected: '$EXPECTED5'"
    echo "Got:      '$RESULT5'"
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
