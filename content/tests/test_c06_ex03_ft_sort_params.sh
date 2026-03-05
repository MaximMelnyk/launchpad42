#!/bin/bash
# test_c06_ex03_ft_sort_params.sh — hash verification
# Usage: bash test_c06_ex03_ft_sort_params.sh [source_dir]
set -e

EXERCISE_ID="c06_ex03_ft_sort_params"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C06 ex03: ft_sort_params — sort argv in ASCII order)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_sort_params.c" ]; then
    echo "FAILED: File 'ft_sort_params.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(|\bstrcmp\s*\(|\bqsort\s*\(' "${SRC_DIR}/ft_sort_params.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_sort_params.c (printf/scanf/puts/strcmp/qsort)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_sort_params.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_sort_params.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_sort_params.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/ft_sort_params.c"

# --- Test 1: Basic sorting ---
echo "Test 1: Basic alphabetical sorting..."
RESULT1=$(/tmp/${EXERCISE_ID}_test cherry apple banana)
EXPECTED1=$(printf 'apple\nbanana\ncherry')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic sorting"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 2: Numbers as strings (ASCII order) ---
echo "Test 2: Numbers as strings (ASCII order)..."
RESULT2=$(/tmp/${EXERCISE_ID}_test 42 100 9 200)
EXPECTED2=$(printf '100\n200\n42\n9')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: ASCII number sorting"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 3: Already sorted ---
echo "Test 3: Already sorted input..."
RESULT3=$(/tmp/${EXERCISE_ID}_test alpha beta gamma)
EXPECTED3=$(printf 'alpha\nbeta\ngamma')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Already sorted"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 4: Reverse sorted ---
echo "Test 4: Reverse sorted input..."
RESULT4=$(/tmp/${EXERCISE_ID}_test z y x w)
EXPECTED4=$(printf 'w\nx\ny\nz')

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Reverse sorted"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 5: Single argument ---
echo "Test 5: Single argument..."
RESULT5=$(/tmp/${EXERCISE_ID}_test alone)
EXPECTED5="alone"

if [ "$RESULT5" != "$EXPECTED5" ]; then
    echo "FAILED: Single argument"
    echo "Expected: '$EXPECTED5'"
    echo "Got:      '$RESULT5'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 6: No arguments ---
echo "Test 6: No arguments..."
RESULT6=$(/tmp/${EXERCISE_ID}_test)
EXPECTED6=""

if [ "$RESULT6" != "$EXPECTED6" ]; then
    echo "FAILED: No arguments (should print nothing)"
    echo "Expected: ''"
    echo "Got:      '$RESULT6'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 7: Mixed case (uppercase < lowercase in ASCII) ---
echo "Test 7: Mixed case ASCII order..."
RESULT7=$(/tmp/${EXERCISE_ID}_test banana Apple cherry)
EXPECTED7=$(printf 'Apple\nbanana\ncherry')

if [ "$RESULT7" != "$EXPECTED7" ]; then
    echo "FAILED: Mixed case sorting"
    echo "Expected: '$EXPECTED7'"
    echo "Got:      '$RESULT7'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 8: Duplicates ---
echo "Test 8: Duplicate arguments..."
RESULT8=$(/tmp/${EXERCISE_ID}_test bb aa bb aa)
EXPECTED8=$(printf 'aa\naa\nbb\nbb')

if [ "$RESULT8" != "$EXPECTED8" ]; then
    echo "FAILED: Duplicates"
    echo "Expected: '$EXPECTED8'"
    echo "Got:      '$RESULT8'"
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
