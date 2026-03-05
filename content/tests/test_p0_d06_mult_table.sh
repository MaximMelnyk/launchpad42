#!/bin/bash
# test_p0_d06_mult_table.sh — hash verification
# Usage: bash test_p0_d06_mult_table.sh [source_dir]
set -e

EXERCISE_ID="p0_d06_mult_table"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
for f in main.c ft_putchar.c ft_putstr.c ft_putnbr.c; do
    if [ ! -f "${SRC_DIR}/${f}" ]; then
        echo "FAILED: File '${f}' not found"
        exit 1
    fi
done

# Check for forbidden functions and loops
for f in main.c ft_putchar.c ft_putstr.c ft_putnbr.c; do
    if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

if grep -qE '\bfor\s*\(' "${SRC_DIR}/main.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in main.c (use 'while')"
    exit 1
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/main.c" "${SRC_DIR}/ft_putchar.c" \
    "${SRC_DIR}/ft_putstr.c" "${SRC_DIR}/ft_putnbr.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

# Run and capture output
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf '9 x 1 = 9\n9 x 2 = 18\n9 x 3 = 27\n9 x 4 = 36\n9 x 5 = 45\n9 x 6 = 54\n9 x 7 = 63\n9 x 8 = 72\n9 x 9 = 81')

if [ "$RESULT" == "$EXPECTED" ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    show_compile_count
    echo "Code: $HASH"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 0
else
    echo "FAILED"
    echo "Expected:"
    echo "$EXPECTED"
    echo "Got:"
    echo "$RESULT"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
