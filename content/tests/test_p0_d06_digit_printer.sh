#!/bin/bash
# test_p0_d06_digit_printer.sh — hash verification
# Usage: bash test_p0_d06_digit_printer.sh [source_dir]
set -e

EXERCISE_ID="p0_d06_digit_printer"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_print_numbers.c" ]; then
    echo "FAILED: File 'ft_print_numbers.c' not found"
    exit 1
fi
if [ ! -f "${SRC_DIR}/ft_putchar.c" ]; then
    echo "FAILED: File 'ft_putchar.c' not found"
    exit 1
fi

# Check for forbidden functions/loops
for f in ft_print_numbers.c ft_putchar.c; do
    if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_print_numbers.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_print_numbers.c (use 'while')"
    exit 1
fi

# Create test main
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_print_numbers(void);
void	ft_putchar(char c);

int	main(void)
{
	ft_print_numbers();
	ft_putchar('\n');
	return (0);
}
TESTEOF

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_print_numbers.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

# Run and capture output
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="0123456789"

if [ "$RESULT" == "$EXPECTED" ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    echo "Code: $HASH"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 0
else
    echo "FAILED"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$RESULT'"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
