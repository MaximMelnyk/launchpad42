#!/bin/bash
# test_c01_ex02_ft_swap.sh — hash verification
# Usage: bash test_c01_ex02_ft_swap.sh [source_dir]
set -e

EXERCISE_ID="c01_ex02_ft_swap"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C01 ex02: ft_swap — swap two ints via pointers)"
echo ""

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_swap.c" ]; then
    echo "FAILED: File 'ft_swap.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_swap.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_swap.c (printf/scanf/puts)"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_swap.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Basic swap ---
echo "Test 1: Basic swap..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_swap(int *a, int *b);

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

	x = 42;
	y = 21;
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	ft_swap(&x, &y);
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_swap.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '42 21\n21 42')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic swap"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c

# --- Test 2: Negative numbers ---
echo "Test 2: Negative numbers..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
#include <unistd.h>

void	ft_swap(int *a, int *b);

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

	x = -5;
	y = 100;
	ft_swap(&x, &y);
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_swap.c" /tmp/${EXERCISE_ID}_main2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="100 -5"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Negative numbers"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c

# --- Test 3: Same values ---
echo "Test 3: Same values..."
cat > /tmp/${EXERCISE_ID}_main3.c << 'TESTEOF'
#include <unistd.h>

void	ft_swap(int *a, int *b);

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

	x = 7;
	y = 7;
	ft_swap(&x, &y);
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_swap.c" /tmp/${EXERCISE_ID}_main3.c

RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3="7 7"

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Same values"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
