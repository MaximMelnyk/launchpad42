#!/bin/bash
# test_p0_d02_ft_putchar.sh — hash verification
# Usage: bash test_p0_d02_ft_putchar.sh [source_dir]
set -e

EXERCISE_ID="p0_d02_ft_putchar"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_putchar.c" ]; then
    echo "FAILED: File 'ft_putchar.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/ft_putchar.c" 2>/dev/null; then
    echo "FAILED: Forbidden function detected (printf/scanf/puts)"
    exit 1
fi

# Create test main
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_putchar(char c);

int	main(void)
{
	ft_putchar('H');
	ft_putchar('i');
	ft_putchar('!');
	ft_putchar('\n');
	ft_putchar('0');
	ft_putchar(' ');
	ft_putchar('~');
	return (0);
}
TESTEOF

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

# Run and capture output
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf 'Hi!\n0 ~')

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
