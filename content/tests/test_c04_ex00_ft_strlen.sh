#!/bin/bash
# test_c04_ex00_ft_strlen.sh — hash verification
# Usage: bash test_c04_ex00_ft_strlen.sh [source_dir]
set -e

EXERCISE_ID="c04_ex00_ft_strlen"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C04: ft_strlen — review exercise)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strlen.c" ]; then
    echo "FAILED: File 'ft_strlen.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_strlen.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strlen.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strlen.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_strlen.c (use 'while')"
    exit 1
fi

# Check for forbidden strlen usage
if grep -qE '\bstrlen\s*\(' "${SRC_DIR}/ft_strlen.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'strlen' in ft_strlen.c"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strlen.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test: All cases ---
echo "Test: All cases..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_strlen(char *str);

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
	if (nb == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (nb < 0)
	{
		ft_putchar('-');
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}

int	main(void)
{
	ft_putnbr(ft_strlen("Hello"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen(""));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("42 Paris Piscine"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("a"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("abcdefghij"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_strlen.c" /tmp/${EXERCISE_ID}_main.c
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf '5\n0\n16\n1\n10')

if [ "$RESULT" != "$EXPECTED" ]; then
    echo "FAILED"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$RESULT'"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
