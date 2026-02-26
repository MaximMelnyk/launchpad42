#!/bin/bash
# test_c05_ex06_ft_is_prime.sh — hash verification
# Usage: bash test_c05_ex06_ft_is_prime.sh [source_dir]
set -e

EXERCISE_ID="c05_ex06_ft_is_prime"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C05: ft_is_prime)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_is_prime.c" ]; then
    echo "FAILED: File 'ft_is_prime.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(|\bsqrt\s*\(' "${SRC_DIR}/ft_is_prime.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_is_prime.c (printf/scanf/puts/sqrt)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_is_prime.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_is_prime.c (use 'while')"
    exit 1
fi

# Check for forbidden includes
if grep -qE '#include\s*<math\.h>' "${SRC_DIR}/ft_is_prime.c" 2>/dev/null; then
    echo "FAILED: Forbidden include <math.h> in ft_is_prime.c"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_is_prime.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Non-primes (0, 1, 4, 6, 42) ---
echo "Test 1: Non-primes (0, 1, 4, 6, 42)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_is_prime(int nb);

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
	ft_putnbr(ft_is_prime(0));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(1));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(4));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(6));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(42));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_is_prime.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '0\n0\n0\n0\n0')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Non-primes"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Primes (2, 3, 5, 7, 13, 97) ---
echo "Test 2: Primes (2, 3, 5, 7, 13, 97)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_is_prime(int nb);

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
	ft_putnbr(ft_is_prime(2));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(3));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(5));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(7));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(13));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(97));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_is_prime.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '1\n1\n1\n1\n1\n1')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Primes"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: Edge cases (negative, large prime) ---
echo "Test 3: Edge cases (negative, large prime 2147483647)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_is_prime(int nb);

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
	ft_putnbr(ft_is_prime(-7));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(-1));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(2147483647));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_is_prime.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf '0\n0\n1')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Edge cases"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3

# --- Test 4: Boundary composites near primes ---
echo "Test 4: Boundary composites (8, 9, 10, 11, 49, 51)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_is_prime(int nb);

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
	ft_putnbr(ft_is_prime(8));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(9));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(10));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(11));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(49));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(51));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_is_prime.c" /tmp/${EXERCISE_ID}_main.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4=$(printf '0\n0\n0\n1\n0\n0')

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Boundary composites"
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
