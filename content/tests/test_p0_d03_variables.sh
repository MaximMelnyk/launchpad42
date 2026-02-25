#!/bin/bash
# test_p0_d03_variables.sh — hash verification
# Usage: bash test_p0_d03_variables.sh [source_dir]
set -e

EXERCISE_ID="p0_d03_variables"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/main.c" ]; then
    echo "FAILED: File 'main.c' not found"
    exit 1
fi
if [ ! -f "${SRC_DIR}/ft_putchar.c" ]; then
    echo "FAILED: File 'ft_putchar.c' not found"
    exit 1
fi

# Check for forbidden functions
for f in main.c ft_putchar.c; do
    if [ -f "${SRC_DIR}/${f}" ] && grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/main.c" "${SRC_DIR}/ft_putchar.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

# Run and capture output
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="42Z"

if [ "$RESULT" == "$EXPECTED" ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    echo "Code: $HASH"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 0
else
    echo "FAILED"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$RESULT'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
