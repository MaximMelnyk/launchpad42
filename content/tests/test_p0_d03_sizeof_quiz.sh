#!/bin/bash
# test_p0_d03_sizeof_quiz.sh — hash verification
# Usage: bash test_p0_d03_sizeof_quiz.sh [source_dir]
set -e

EXERCISE_ID="p0_d03_sizeof_quiz"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
for f in main.c ft_putchar.c ft_putstr.c ft_putnbr.c; do
    if [ ! -f "${SRC_DIR}/${f}" ]; then
        echo "FAILED: File '${f}' not found"
        exit 1
    fi
done

# Check for forbidden functions
for f in main.c ft_putchar.c ft_putstr.c ft_putnbr.c; do
    if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

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

# Verify format (sizes may vary by platform)
PASS=1
if ! echo "$RESULT" | grep -q "^char: [0-9]"; then
    echo "FAILED: Missing or malformed 'char: X' line"
    PASS=0
fi
if ! echo "$RESULT" | grep -q "^int: [0-9]"; then
    echo "FAILED: Missing or malformed 'int: X' line"
    PASS=0
fi
if ! echo "$RESULT" | grep -q "^float: [0-9]"; then
    echo "FAILED: Missing or malformed 'float: X' line"
    PASS=0
fi
if ! echo "$RESULT" | grep -q "^double: [0-9]"; then
    echo "FAILED: Missing or malformed 'double: X' line"
    PASS=0
fi

# Verify char is always 1
CHAR_SIZE=$(echo "$RESULT" | grep "^char:" | sed 's/char: //')
if [ "$CHAR_SIZE" != "1" ]; then
    echo "FAILED: sizeof(char) must be 1, got ${CHAR_SIZE}"
    PASS=0
fi

if [ "$PASS" -eq 1 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    echo "Output: $RESULT"
    echo "Code: $HASH"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 0
else
    echo "FAILED"
    echo "Got: '$RESULT'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
