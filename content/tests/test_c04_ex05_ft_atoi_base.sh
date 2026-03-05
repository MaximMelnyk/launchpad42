#!/bin/bash
# test_c04_ex05_ft_atoi_base.sh — hash verification
# Usage: bash test_c04_ex05_ft_atoi_base.sh [source_dir]
set -e

EXERCISE_ID="c04_ex05_ft_atoi_base"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C04: ft_atoi_base)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_atoi_base.c" ]; then
    echo "FAILED: File 'ft_atoi_base.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(|\batoi\s*\(|\bstrtol\s*\(' "${SRC_DIR}/ft_atoi_base.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_atoi_base.c (printf/scanf/puts/atoi/strtol)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_atoi_base.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_atoi_base.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_atoi_base.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Hex conversion ---
echo "Test 1: Hex conversion..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_atoi_base(char *str, char *base);

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
	ft_putnbr(ft_atoi_base("2A", "0123456789ABCDEF"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("FF", "0123456789ABCDEF"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("0", "0123456789ABCDEF"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_atoi_base.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '42\n255\n0')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Hex conversion"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Binary conversion ---
echo "Test 2: Binary conversion..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_atoi_base(char *str, char *base);

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
	ft_putnbr(ft_atoi_base("1010", "01"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("11111111", "01"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("-1010", "01"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_atoi_base.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '10\n255\n-10')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Binary conversion"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: Whitespace and signs ---
echo "Test 3: Whitespace and signs..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_atoi_base(char *str, char *base);

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
	ft_putnbr(ft_atoi_base("  -2A", "0123456789ABCDEF"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("42", "0123456789"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("   --42", "0123456789"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_atoi_base.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf '-42\n42\n42')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Whitespace and signs"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3

# --- Test 4: Invalid bases ---
echo "Test 4: Invalid bases (should return 0)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_atoi_base(char *str, char *base);

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
	ft_putnbr(ft_atoi_base("42", "0"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("42", "0112"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("42", ""));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("abc", "0123456789"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_atoi_base.c" /tmp/${EXERCISE_ID}_main.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4=$(printf '0\n0\n0\n0')

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Invalid bases"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test4

# --- Test 5: Decimal base (roundtrip) ---
echo "Test 5: Decimal base roundtrip..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_atoi_base(char *str, char *base);

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
	ft_putnbr(ft_atoi_base("2147483647", "0123456789"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("-2147483648", "0123456789"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test5 \
    "${SRC_DIR}/ft_atoi_base.c" /tmp/${EXERCISE_ID}_main.c
RESULT5=$(/tmp/${EXERCISE_ID}_test5)
EXPECTED5=$(printf '2147483647\n-2147483648')

if [ "$RESULT5" != "$EXPECTED5" ]; then
    echo "FAILED: Decimal roundtrip"
    echo "Expected: '$EXPECTED5'"
    echo "Got:      '$RESULT5'"
    rm -f /tmp/${EXERCISE_ID}_test5 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test5 /tmp/${EXERCISE_ID}_main.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
