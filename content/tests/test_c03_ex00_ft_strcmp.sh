#!/bin/bash
# test_c03_ex00_ft_strcmp.sh — hash verification
# Usage: bash test_c03_ex00_ft_strcmp.sh [source_dir]
set -e

EXERCISE_ID="c03_ex00_ft_strcmp"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C03: ft_strcmp)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strcmp.c" ]; then
    echo "FAILED: File 'ft_strcmp.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_strcmp.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strcmp.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strcmp.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_strcmp.c (use 'while')"
    exit 1
fi

# Check for forbidden strcmp usage
if grep -qE '\bstrcmp\s*\(' "${SRC_DIR}/ft_strcmp.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'strcmp' in ft_strcmp.c (implement it yourself)"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strcmp.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Equal strings ---
echo "Test 1: Equal strings..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_strcmp(char *s1, char *s2);

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
	ft_putnbr(ft_strcmp("abc", "abc"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("", ""));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_strcmp.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '0\n0')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Equal strings test"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Different strings ---
echo "Test 2: Different strings..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_strcmp(char *s1, char *s2);

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
	int	r1;
	int	r2;

	r1 = ft_strcmp("abc", "abd");
	r2 = ft_strcmp("abd", "abc");
	if (r1 < 0)
		ft_putchar('-');
	else if (r1 > 0)
		ft_putchar('+');
	else
		ft_putchar('0');
	ft_putchar('\n');
	if (r2 < 0)
		ft_putchar('-');
	else if (r2 > 0)
		ft_putchar('+');
	else
		ft_putchar('0');
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_strcmp.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '-\n+')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Different strings test (sign check)"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: Full integration with exact values ---
echo "Test 3: Full integration..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_strcmp(char *s1, char *s2);

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
	ft_putnbr(ft_strcmp("abc", "abc"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abc", "abd"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abd", "abc"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("", ""));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abc", ""));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("", "abc"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abc", "abcd"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_strcmp.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf '0\n-1\n1\n0\n97\n-97\n-100')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Full integration test"
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
