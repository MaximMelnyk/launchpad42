#!/bin/bash
# test_c08_ex02_ft_abs_h.sh — hash verification
# Usage: bash test_c08_ex02_ft_abs_h.sh [source_dir]
set -e

EXERCISE_ID="c08_ex02_ft_abs_h"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C08 ex02: ft_abs.h — ABS macro)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_abs.h" ]; then
    echo "FAILED: File 'ft_abs.h' not found"
    exit 1
fi

# Check for include guard
if ! grep -q '#ifndef FT_ABS_H' "${SRC_DIR}/ft_abs.h"; then
    echo "FAILED: Missing include guard (#ifndef FT_ABS_H)"
    exit 1
fi

if ! grep -qE '#\s*define FT_ABS_H' "${SRC_DIR}/ft_abs.h"; then
    echo "FAILED: Missing #define FT_ABS_H"
    exit 1
fi

if ! grep -q '#endif' "${SRC_DIR}/ft_abs.h"; then
    echo "FAILED: Missing #endif"
    exit 1
fi

# Check for ABS macro
if ! grep -qE '#\s*define ABS\(' "${SRC_DIR}/ft_abs.h"; then
    echo "FAILED: Missing #define ABS(Value) macro"
    exit 1
fi

# Check for parentheses around macro argument (safety)
if grep -qE '#\s*define ABS\(\s*\w+\s*\)\s+[^(]' "${SRC_DIR}/ft_abs.h"; then
    echo "WARNING: ABS macro body should be wrapped in outer parentheses"
fi

echo "Include guard: OK"
echo "ABS macro found: OK"

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_abs.h" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_abs.h"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_abs.h" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Basic ABS values ---
echo ""
echo "Test 1: Basic ABS values..."

cat > /tmp/${EXERCISE_ID}_main.c << TESTEOF
#include <unistd.h>
#include "${SRC_DIR}/ft_abs.h"

void	ft_putnbr(int nb)
{
	char	c;

	if (nb == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (nb < 0)
	{
		write(1, "-", 1);
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	c = (nb % 10) + '0';
	write(1, &c, 1);
}

int	main(void)
{
	ft_putnbr(ABS(-5));
	write(1, "\n", 1);
	ft_putnbr(ABS(5));
	write(1, "\n", 1);
	ft_putnbr(ABS(0));
	write(1, "\n", 1);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '5\n5\n0')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic ABS values"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 2: Large negative number ---
echo "Test 2: Large negative number..."

cat > /tmp/${EXERCISE_ID}_main.c << TESTEOF
#include <unistd.h>
#include "${SRC_DIR}/ft_abs.h"

void	ft_putnbr(int nb)
{
	char	c;

	if (nb == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (nb < 0)
	{
		write(1, "-", 1);
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	c = (nb % 10) + '0';
	write(1, &c, 1);
}

int	main(void)
{
	ft_putnbr(ABS(-2147483647));
	write(1, "\n", 1);
	ft_putnbr(ABS(-42));
	write(1, "\n", 1);
	ft_putnbr(ABS(1));
	write(1, "\n", 1);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '2147483647\n42\n1')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Large negative number"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 3: Expression as argument (parentheses test) ---
echo "Test 3: Expression as argument (parentheses safety)..."

cat > /tmp/${EXERCISE_ID}_main.c << TESTEOF
#include <unistd.h>
#include "${SRC_DIR}/ft_abs.h"

void	ft_putnbr(int nb)
{
	char	c;

	if (nb < 0)
	{
		write(1, "-", 1);
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	c = (nb % 10) + '0';
	write(1, &c, 1);
}

int	main(void)
{
	int	a;
	int	b;

	a = 3;
	b = 7;
	ft_putnbr(ABS(a - b));
	write(1, "\n", 1);
	ft_putnbr(ABS(b - a));
	write(1, "\n", 1);
	ft_putnbr(ABS(-1 + -2));
	write(1, "\n", 1);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf '4\n4\n3')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Expression as argument (parentheses missing?)"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 4: Double include (guard test) ---
echo "Test 4: Double include (guard test)..."

cat > /tmp/${EXERCISE_ID}_main.c << TESTEOF
#include <unistd.h>
#include "${SRC_DIR}/ft_abs.h"
#include "${SRC_DIR}/ft_abs.h"

int	main(void)
{
	write(1, "G\n", 2);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "FAILED: Double include causes compilation error"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# Cleanup
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
