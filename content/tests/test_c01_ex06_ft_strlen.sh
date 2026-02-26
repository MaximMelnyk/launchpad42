#!/bin/bash
# test_c01_ex06_ft_strlen.sh — hash verification
# Usage: bash test_c01_ex06_ft_strlen.sh [source_dir]
set -e

EXERCISE_ID="c01_ex06_ft_strlen"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C01 ex06: ft_strlen — return string length)"
echo ""

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_strlen.c" ]; then
    echo "FAILED: File 'ft_strlen.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_strlen.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strlen.c (printf/scanf/puts)"
    exit 1
fi

# Check that student doesn't use standard strlen
if grep -qE '#include\s*<string\.h>' "${SRC_DIR}/ft_strlen.c" 2>/dev/null; then
    echo "FAILED: Do not include <string.h> — write your own strlen"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strlen.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_strlen.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strlen.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Basic string lengths ---
echo "Test 1: Basic string lengths..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_strlen(char *str);

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
	ft_putnbr(ft_strlen(""));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("Hello"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("42"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("abcdefghij"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("Piscine 42 Paris 2026"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_strlen.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '0\n5\n2\n10\n21')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic string lengths"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c

# --- Test 2: Various strings ---
echo "Test 2: Various strings..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
#include <unistd.h>

int	ft_strlen(char *str);

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
	ft_putnbr(ft_strlen("A"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("   "));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("tab\there"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_strlen.c" /tmp/${EXERCISE_ID}_main2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '1\n3\n8')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Various strings"
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
