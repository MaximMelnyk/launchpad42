#!/bin/bash
# test_c07_ex01_ft_range.sh — hash verification
# Usage: bash test_c07_ex01_ft_range.sh [source_dir]
set -e

EXERCISE_ID="c07_ex01_ft_range"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C07 ex01: ft_range — create int array [min..max-1])"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_range.c" ]; then
    echo "FAILED: File 'ft_range.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_range.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_range.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_range.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_range.c (use 'while')"
    exit 1
fi

# Check that malloc is used
if ! grep -qE '\bmalloc\s*\(' "${SRC_DIR}/ft_range.c" 2>/dev/null; then
    echo "FAILED: ft_range.c must use malloc"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_range.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Basic range 0..5 ---
echo "Test 1: Range 0 to 5..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

int	*ft_range(int min, int max);

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
	int	*range;
	int	i;

	range = ft_range(0, 5);
	i = 0;
	while (i < 5)
	{
		ft_putnbr(range[i]);
		ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
	free(range);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_range.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1="0 1 2 3 4"

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Range 0 to 5"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Negative range ---
echo "Test 2: Range -3 to 3..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

int	*ft_range(int min, int max);

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
	int	*range;
	int	i;

	range = ft_range(-3, 3);
	i = 0;
	while (i < 6)
	{
		ft_putnbr(range[i]);
		ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
	free(range);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_range.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="-3 -2 -1 0 1 2"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Range -3 to 3"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: min >= max returns NULL ---
echo "Test 3: min >= max returns NULL..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

int	*ft_range(int min, int max);

int	main(void)
{
	int	*range;

	range = ft_range(5, 5);
	if (range == NULL)
		write(1, "NULL1", 5);
	ft_range(10, 3);
	range = ft_range(10, 3);
	if (range == NULL)
		write(1, "NULL2", 5);
	write(1, "\n", 1);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_range.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3="NULL1NULL2"

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: min >= max should return NULL"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3

# --- Test 4: Single element range ---
echo "Test 4: Single element range (0, 1)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

int	*ft_range(int min, int max);

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
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
	int	*range;

	range = ft_range(0, 1);
	ft_putnbr(range[0]);
	ft_putchar('\n');
	free(range);
	range = ft_range(42, 43);
	ft_putnbr(range[0]);
	ft_putchar('\n');
	free(range);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_range.c" /tmp/${EXERCISE_ID}_main.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4=$(printf '0\n42')

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Single element range"
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
