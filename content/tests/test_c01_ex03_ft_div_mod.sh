#!/bin/bash
# test_c01_ex03_ft_div_mod.sh — hash verification
# Usage: bash test_c01_ex03_ft_div_mod.sh [source_dir]
set -e

EXERCISE_ID="c01_ex03_ft_div_mod"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C01 ex03: ft_div_mod — division and modulo via pointers)"
echo ""

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_div_mod.c" ]; then
    echo "FAILED: File 'ft_div_mod.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_div_mod.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_div_mod.c (printf/scanf/puts)"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_div_mod.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Basic div_mod ---
echo "Test 1: Basic division and modulo..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_div_mod(int a, int b, int *div, int *mod);

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
	int	d;
	int	m;

	ft_div_mod(10, 3, &d, &m);
	ft_putnbr(d);
	ft_putchar(' ');
	ft_putnbr(m);
	ft_putchar('\n');
	ft_div_mod(42, 10, &d, &m);
	ft_putnbr(d);
	ft_putchar(' ');
	ft_putnbr(m);
	ft_putchar('\n');
	ft_div_mod(7, 7, &d, &m);
	ft_putnbr(d);
	ft_putchar(' ');
	ft_putnbr(m);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_div_mod.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '3 1\n4 2\n1 0')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic division and modulo"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c

# --- Test 2: Edge cases ---
echo "Test 2: Edge cases..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
#include <unistd.h>

void	ft_div_mod(int a, int b, int *div, int *mod);

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
	int	d;
	int	m;

	ft_div_mod(0, 5, &d, &m);
	ft_putnbr(d);
	ft_putchar(' ');
	ft_putnbr(m);
	ft_putchar('\n');
	ft_div_mod(1, 3, &d, &m);
	ft_putnbr(d);
	ft_putchar(' ');
	ft_putnbr(m);
	ft_putchar('\n');
	ft_div_mod(100, 1, &d, &m);
	ft_putnbr(d);
	ft_putchar(' ');
	ft_putnbr(m);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_div_mod.c" /tmp/${EXERCISE_ID}_main2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '0 0\n0 1\n100 0')

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
    show_compile_count
echo "Code: $HASH"
exit 0
