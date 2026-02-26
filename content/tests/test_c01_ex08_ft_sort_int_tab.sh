#!/bin/bash
# test_c01_ex08_ft_sort_int_tab.sh — hash verification
# Usage: bash test_c01_ex08_ft_sort_int_tab.sh [source_dir]
set -e

EXERCISE_ID="c01_ex08_ft_sort_int_tab"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C01 ex08: ft_sort_int_tab — sort int array ascending)"
echo ""

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_sort_int_tab.c" ]; then
    echo "FAILED: File 'ft_sort_int_tab.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_sort_int_tab.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_sort_int_tab.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_sort_int_tab.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_sort_int_tab.c (use 'while')"
    exit 1
fi

# Check for forbidden stdlib sort
if grep -qE '\bqsort\b' "${SRC_DIR}/ft_sort_int_tab.c" 2>/dev/null; then
    echo "FAILED: Do not use qsort — write your own sorting"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_sort_int_tab.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Basic unsorted array ---
echo "Test 1: Sort [5,3,1,4,2]..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_sort_int_tab(int *tab, int size);

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
	int	a[5];

	a[0] = 5;
	a[1] = 3;
	a[2] = 1;
	a[3] = 4;
	a[4] = 2;
	ft_sort_int_tab(a, 5);
	ft_print_tab(a, 5);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_sort_int_tab.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1="1 2 3 4 5"

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Sort [5,3,1,4,2]"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c

# --- Test 2: Negative numbers ---
echo "Test 2: Sort with negative numbers..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
#include <unistd.h>

void	ft_sort_int_tab(int *tab, int size);

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
	int	b[3];

	b[0] = 42;
	b[1] = -1;
	b[2] = 0;
	ft_sort_int_tab(b, 3);
	ft_print_tab(b, 3);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_sort_int_tab.c" /tmp/${EXERCISE_ID}_main2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="-1 0 42"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Sort with negatives"
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

void	ft_sort_int_tab(int *tab, int size);

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
	int	c[1];

	c[0] = 7;
	ft_sort_int_tab(c, 1);
	ft_putnbr(c[0]);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_sort_int_tab.c" /tmp/${EXERCISE_ID}_main3.c

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

# --- Test 4: Duplicates ---
echo "Test 4: Array with duplicates..."
cat > /tmp/${EXERCISE_ID}_main4.c << 'TESTEOF'
#include <unistd.h>

void	ft_sort_int_tab(int *tab, int size);

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
	int	d[6];

	d[0] = 3;
	d[1] = 3;
	d[2] = 1;
	d[3] = 1;
	d[4] = 2;
	d[5] = 2;
	ft_sort_int_tab(d, 6);
	ft_print_tab(d, 6);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_sort_int_tab.c" /tmp/${EXERCISE_ID}_main4.c

RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4="1 1 2 2 3 3"

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Duplicates"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main4.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main4.c

# --- Test 5: Already sorted ---
echo "Test 5: Already sorted array..."
cat > /tmp/${EXERCISE_ID}_main5.c << 'TESTEOF'
#include <unistd.h>

void	ft_sort_int_tab(int *tab, int size);

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
	int	e[4];

	e[0] = 1;
	e[1] = 2;
	e[2] = 3;
	e[3] = 4;
	ft_sort_int_tab(e, 4);
	ft_print_tab(e, 4);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test5 \
    "${SRC_DIR}/ft_sort_int_tab.c" /tmp/${EXERCISE_ID}_main5.c

RESULT5=$(/tmp/${EXERCISE_ID}_test5)
EXPECTED5="1 2 3 4"

if [ "$RESULT5" != "$EXPECTED5" ]; then
    echo "FAILED: Already sorted"
    echo "Expected: '$EXPECTED5'"
    echo "Got:      '$RESULT5'"
    rm -f /tmp/${EXERCISE_ID}_test5 /tmp/${EXERCISE_ID}_main5.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test5 /tmp/${EXERCISE_ID}_main5.c

# --- Test 6: Reverse sorted ---
echo "Test 6: Reverse sorted array..."
cat > /tmp/${EXERCISE_ID}_main6.c << 'TESTEOF'
#include <unistd.h>

void	ft_sort_int_tab(int *tab, int size);

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
	int	f[4];

	f[0] = 4;
	f[1] = 3;
	f[2] = 2;
	f[3] = 1;
	ft_sort_int_tab(f, 4);
	ft_print_tab(f, 4);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test6 \
    "${SRC_DIR}/ft_sort_int_tab.c" /tmp/${EXERCISE_ID}_main6.c

RESULT6=$(/tmp/${EXERCISE_ID}_test6)
EXPECTED6="1 2 3 4"

if [ "$RESULT6" != "$EXPECTED6" ]; then
    echo "FAILED: Reverse sorted"
    echo "Expected: '$EXPECTED6'"
    echo "Got:      '$RESULT6'"
    rm -f /tmp/${EXERCISE_ID}_test6 /tmp/${EXERCISE_ID}_main6.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test6 /tmp/${EXERCISE_ID}_main6.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
