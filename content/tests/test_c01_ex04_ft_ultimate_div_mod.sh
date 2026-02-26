#!/bin/bash
# test_c01_ex04_ft_ultimate_div_mod.sh — hash verification
# Usage: bash test_c01_ex04_ft_ultimate_div_mod.sh [source_dir]
set -e

EXERCISE_ID="c01_ex04_ft_ultimate_div_mod"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C01 ex04: ft_ultimate_div_mod — div/mod overwriting original values)"
echo ""

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_ultimate_div_mod.c" ]; then
    echo "FAILED: File 'ft_ultimate_div_mod.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_ultimate_div_mod.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_ultimate_div_mod.c (printf/scanf/puts)"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_ultimate_div_mod.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Basic ultimate_div_mod ---
echo "Test 1: Basic ultimate div_mod..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_ultimate_div_mod(int *a, int *b);

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
	long	n;

	n = nb;
	if (n < 0)
	{
		ft_putchar('-');
		n = -n;
	}
	if (n >= 10)
		ft_putnbr(n / 10);
	ft_putchar(n % 10 + '0');
}

int	main(void)
{
	int	x;
	int	y;

	x = 10;
	y = 3;
	ft_ultimate_div_mod(&x, &y);
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	x = 42;
	y = 10;
	ft_ultimate_div_mod(&x, &y);
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	x = 100;
	y = 7;
	ft_ultimate_div_mod(&x, &y);
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_ultimate_div_mod.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '3 1\n4 2\n14 2')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic ultimate div_mod"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c

# --- Test 2: Edge cases ---
echo "Test 2: Edge cases (exact division, small/large)..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
#include <unistd.h>

void	ft_ultimate_div_mod(int *a, int *b);

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
	long	n;

	n = nb;
	if (n < 0)
	{
		ft_putchar('-');
		n = -n;
	}
	if (n >= 10)
		ft_putnbr(n / 10);
	ft_putchar(n % 10 + '0');
}

int	main(void)
{
	int	x;
	int	y;

	x = 9;
	y = 3;
	ft_ultimate_div_mod(&x, &y);
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	x = 1;
	y = 5;
	ft_ultimate_div_mod(&x, &y);
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_ultimate_div_mod.c" /tmp/${EXERCISE_ID}_main2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '3 0\n0 1')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Edge cases"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
