#!/bin/bash
# test_c01_ex07_ft_rev_int_tab.sh — hash verification
# Usage: bash test_c01_ex07_ft_rev_int_tab.sh [source_dir]
set -e

EXERCISE_ID="c01_ex07_ft_rev_int_tab"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C01 ex07: ft_rev_int_tab — reverse int array in-place)"
echo ""

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_rev_int_tab.c" ]; then
    echo "FAILED: File 'ft_rev_int_tab.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_rev_int_tab.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_rev_int_tab.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_rev_int_tab.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_rev_int_tab.c (use 'while')"
    exit 1
fi

# Check for malloc (should not allocate new array)
if grep -qE '\bmalloc\b' "${SRC_DIR}/ft_rev_int_tab.c" 2>/dev/null; then
    echo "FAILED: Do not use malloc — reverse in-place"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_rev_int_tab.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Odd-length array ---
echo "Test 1: Reverse array [1,2,3,4,5]..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_rev_int_tab(int *tab, int size);

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

void	ft_print_tab(int *tab, int size)
{
	int	i;

	i = 0;
	while (i < size)
	{
		ft_putnbr(tab[i]);
		if (i < size - 1)
			ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
}

int	main(void)
{
	int	arr[5];

	arr[0] = 1;
	arr[1] = 2;
	arr[2] = 3;
	arr[3] = 4;
	arr[4] = 5;
	ft_print_tab(arr, 5);
	ft_rev_int_tab(arr, 5);
	ft_print_tab(arr, 5);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_rev_int_tab.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '1 2 3 4 5\n5 4 3 2 1')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Reverse odd-length array"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c

# --- Test 2: Even-length array with negatives ---
echo "Test 2: Reverse array [42,21,0,-1]..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
#include <unistd.h>

void	ft_rev_int_tab(int *tab, int size);

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

void	ft_print_tab(int *tab, int size)
{
	int	i;

	i = 0;
	while (i < size)
	{
		ft_putnbr(tab[i]);
		if (i < size - 1)
			ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
}

int	main(void)
{
	int	arr[4];

	arr[0] = 42;
	arr[1] = 21;
	arr[2] = 0;
	arr[3] = -1;
	ft_rev_int_tab(arr, 4);
	ft_print_tab(arr, 4);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_rev_int_tab.c" /tmp/${EXERCISE_ID}_main2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="-1 0 21 42"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Reverse even-length with negatives"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c

# --- Test 3: Single element ---
echo "Test 3: Single element array..."
cat > /tmp/${EXERCISE_ID}_main3.c << 'TESTEOF'
#include <unistd.h>

void	ft_rev_int_tab(int *tab, int size);

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
	int	arr[1];

	arr[0] = 7;
	ft_rev_int_tab(arr, 1);
	ft_putnbr(arr[0]);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_rev_int_tab.c" /tmp/${EXERCISE_ID}_main3.c

RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3="7"

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Single element"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c

# --- Test 4: Double reverse ---
echo "Test 4: Double reverse restores original..."
cat > /tmp/${EXERCISE_ID}_main4.c << 'TESTEOF'
#include <unistd.h>

void	ft_rev_int_tab(int *tab, int size);

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

void	ft_print_tab(int *tab, int size)
{
	int	i;

	i = 0;
	while (i < size)
	{
		ft_putnbr(tab[i]);
		if (i < size - 1)
			ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
}

int	main(void)
{
	int	arr[3];

	arr[0] = 10;
	arr[1] = 20;
	arr[2] = 30;
	ft_rev_int_tab(arr, 3);
	ft_rev_int_tab(arr, 3);
	ft_print_tab(arr, 3);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_rev_int_tab.c" /tmp/${EXERCISE_ID}_main4.c

RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4="10 20 30"

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Double reverse"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main4.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main4.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
