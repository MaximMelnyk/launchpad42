#!/bin/bash
# test_p0_d05_range_check.sh — hash verification
# Usage: bash test_p0_d05_range_check.sh [source_dir]
set -e

EXERCISE_ID="p0_d05_range_check"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_is_in_range.c" ]; then
    echo "FAILED: File 'ft_is_in_range.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/ft_is_in_range.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_is_in_range.c (printf/scanf/puts)"
    exit 1
fi

# Create test main
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int		ft_is_in_range(int value, int min, int max);

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}

int	main(void)
{
	ft_putnbr(ft_is_in_range(5, 1, 10));
	ft_putchar('\n');
	ft_putnbr(ft_is_in_range(0, 1, 10));
	ft_putchar('\n');
	ft_putnbr(ft_is_in_range(10, 1, 10));
	ft_putchar('\n');
	ft_putnbr(ft_is_in_range(-5, -10, -1));
	ft_putchar('\n');
	ft_putnbr(ft_is_in_range(100, 1, 10));
	ft_putchar('\n');
	ft_putnbr(ft_is_in_range(1, 1, 1));
	ft_putchar('\n');
	ft_putnbr(ft_is_in_range(0, 0, 0));
	ft_putchar('\n');
	return (0);
}
TESTEOF

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_is_in_range.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

# Run and capture output
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf '1\n0\n1\n1\n0\n1\n1')

if [ "$RESULT" == "$EXPECTED" ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    show_compile_count
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
