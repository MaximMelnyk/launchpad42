#!/bin/bash
# test_c06_ex02_ft_rev_params.sh — hash verification
# Usage: bash test_c06_ex02_ft_rev_params.sh [source_dir]
set -e

EXERCISE_ID="c06_ex02_ft_rev_params"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C06 ex02: ft_rev_params — print params in reverse order)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_rev_params.c" ]; then
    echo "FAILED: File 'ft_rev_params.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_rev_params.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_rev_params.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_rev_params.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_rev_params.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_rev_params.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/ft_rev_params.c"

# --- Test 1: Three arguments ---
echo "Test 1: Three arguments reversed..."
RESULT1=$(/tmp/${EXERCISE_ID}_test hello world 42)
EXPECTED1=$(printf '42\nworld\nhello')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Three arguments reversed"
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

# --- Test 4: Five arguments ---
echo "Test 4: Five arguments..."
RESULT4=$(/tmp/${EXERCISE_ID}_test a b c d e)
EXPECTED4=$(printf 'e\nd\nc\nb\na')

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Five arguments reversed"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 5: Two identical arguments ---
echo "Test 5: Two identical arguments..."
RESULT5=$(/tmp/${EXERCISE_ID}_test same same)
EXPECTED5=$(printf 'same\nsame')

if [ "$RESULT5" != "$EXPECTED5" ]; then
    echo "FAILED: Two identical arguments"
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
