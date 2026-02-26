#!/bin/bash
# test_c05_ex04_ft_fibonacci.sh — hash verification
# Usage: bash test_c05_ex04_ft_fibonacci.sh [source_dir]
set -e

EXERCISE_ID="c05_ex04_ft_fibonacci"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C05: ft_fibonacci)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_fibonacci.c" ]; then
    echo "FAILED: File 'ft_fibonacci.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_fibonacci.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_fibonacci.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_fibonacci.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_fibonacci.c (use 'while')"
    exit 1
fi

# Check that it uses recursion
if ! grep -c 'ft_fibonacci' "${SRC_DIR}/ft_fibonacci.c" 2>/dev/null | grep -q '[3-9]\|[1-9][0-9]'; then
    echo "WARNING: Function may not use recursion (ft_fibonacci appears fewer than 3 times)"
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_fibonacci.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Base cases (0, 1, 2) ---
echo "Test 1: Base cases (0, 1, 2)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_fibonacci(int index);

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
	ft_putnbr(ft_fibonacci(0));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(1));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(2));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_fibonacci.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '0\n1\n1')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Base cases"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Normal cases (7, 10, 15) ---
echo "Test 2: Normal cases (7, 10, 15)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_fibonacci(int index);

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
	ft_putnbr(ft_fibonacci(7));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(10));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(15));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_fibonacci.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '13\n55\n610')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Normal cases"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: Negative index ---
echo "Test 3: Negative index..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_fibonacci(int index);

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
	ft_putnbr(ft_fibonacci(-1));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(-3));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(-100));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_fibonacci.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf '-1\n-1\n-1')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Negative index"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3

# --- Test 4: Sequential values check ---
echo "Test 4: Sequential values (3, 4, 5, 6)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_fibonacci(int index);

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
	ft_putnbr(ft_fibonacci(3));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(4));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(5));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(6));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_fibonacci.c" /tmp/${EXERCISE_ID}_main.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4=$(printf '2\n3\n5\n8')

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Sequential values"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
