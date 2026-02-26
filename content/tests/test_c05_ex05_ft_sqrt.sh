#!/bin/bash
# test_c05_ex05_ft_sqrt.sh — hash verification
# Usage: bash test_c05_ex05_ft_sqrt.sh [source_dir]
set -e

EXERCISE_ID="c05_ex05_ft_sqrt"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C05: ft_sqrt)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_sqrt.c" ]; then
    echo "FAILED: File 'ft_sqrt.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(|\bsqrt\s*\(|\bpow\s*\(' "${SRC_DIR}/ft_sqrt.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_sqrt.c (printf/scanf/puts/sqrt/pow)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_sqrt.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_sqrt.c (use 'while')"
    exit 1
fi

# Check for forbidden includes
if grep -qE '#include\s*<math\.h>' "${SRC_DIR}/ft_sqrt.c" 2>/dev/null; then
    echo "FAILED: Forbidden include <math.h> in ft_sqrt.c"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_sqrt.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Perfect squares ---
echo "Test 1: Perfect squares..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_sqrt(int nb);

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
	ft_putnbr(ft_sqrt(1));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(4));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(9));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(25));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(100));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(144));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_sqrt.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '1\n2\n3\n5\n10\n12')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Perfect squares"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Non-perfect squares ---
echo "Test 2: Non-perfect squares..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_sqrt(int nb);

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
	ft_putnbr(ft_sqrt(2));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(3));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(5));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(42));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(99));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_sqrt.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '0\n0\n0\n0\n0')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Non-perfect squares"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: Edge cases (0, negative, large perfect square) ---
echo "Test 3: Edge cases (0, negative, large)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_sqrt(int nb);

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
	ft_putnbr(ft_sqrt(0));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(-4));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(-1));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(2147395600));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(2147483647));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_sqrt.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf '0\n0\n0\n46340\n0')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Edge cases"
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
echo "Code: $HASH"
exit 0
