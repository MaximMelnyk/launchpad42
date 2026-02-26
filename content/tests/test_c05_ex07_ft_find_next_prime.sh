#!/bin/bash
# test_c05_ex07_ft_find_next_prime.sh — hash verification
# Usage: bash test_c05_ex07_ft_find_next_prime.sh [source_dir]
set -e

EXERCISE_ID="c05_ex07_ft_find_next_prime"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C05: ft_find_next_prime)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_find_next_prime.c" ]; then
    echo "FAILED: File 'ft_find_next_prime.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(|\bsqrt\s*\(' "${SRC_DIR}/ft_find_next_prime.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_find_next_prime.c (printf/scanf/puts/sqrt)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_find_next_prime.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_find_next_prime.c (use 'while')"
    exit 1
fi

# Check for forbidden includes
if grep -qE '#include\s*<math\.h>' "${SRC_DIR}/ft_find_next_prime.c" 2>/dev/null; then
    echo "FAILED: Forbidden include <math.h> in ft_find_next_prime.c"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_find_next_prime.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Small values and boundaries ---
echo "Test 1: Small values (0, 1, 2, 3)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_find_next_prime(int nb);

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
	ft_putnbr(ft_find_next_prime(0));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(1));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(2));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(3));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_find_next_prime.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '2\n2\n2\n3')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Small values"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Composites that need next prime ---
echo "Test 2: Composites (4, 14, 42, 100)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_find_next_prime(int nb);

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
	ft_putnbr(ft_find_next_prime(4));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(14));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(42));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(100));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_find_next_prime.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '5\n17\n43\n101')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Composites"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: Already prime ---
echo "Test 3: Already prime (5, 13, 97, 101)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_find_next_prime(int nb);

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
	ft_putnbr(ft_find_next_prime(5));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(13));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(97));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(101));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_find_next_prime.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf '5\n13\n97\n101')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Already prime"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3

# --- Test 4: Negative numbers ---
echo "Test 4: Negative numbers..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_find_next_prime(int nb);

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
	ft_putnbr(ft_find_next_prime(-10));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(-1));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_find_next_prime.c" /tmp/${EXERCISE_ID}_main.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4=$(printf '2\n2')

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Negative numbers"
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
