#!/bin/bash
# test_c05_ex02_ft_iterative_power.sh — hash verification
# Usage: bash test_c05_ex02_ft_iterative_power.sh [source_dir]
set -e

EXERCISE_ID="c05_ex02_ft_iterative_power"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C05: ft_iterative_power)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_iterative_power.c" ]; then
    echo "FAILED: File 'ft_iterative_power.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(|\bpow\s*\(' "${SRC_DIR}/ft_iterative_power.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_iterative_power.c (printf/scanf/puts/pow)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_iterative_power.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_iterative_power.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_iterative_power.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Power of 0 (edge cases) ---
echo "Test 1: Power of 0 (edge cases)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_iterative_power(int nb, int power);

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
	ft_putnbr(ft_iterative_power(2, 0));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(0, 0));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(100, 0));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(-5, 0));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_iterative_power.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '1\n1\n1\n1')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Power of 0"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Normal cases ---
echo "Test 2: Normal cases..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_iterative_power(int nb, int power);

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
	ft_putnbr(ft_iterative_power(2, 1));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(2, 10));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(3, 5));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(1, 100));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(0, 5));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_iterative_power.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '2\n1024\n243\n1\n0')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Normal cases"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: Negative power ---
echo "Test 3: Negative power..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_iterative_power(int nb, int power);

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
	ft_putnbr(ft_iterative_power(2, -1));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(5, -3));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_iterative_power.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf '0\n0')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Negative power"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
