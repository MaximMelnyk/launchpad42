#!/bin/bash
# test_c03_ex05_ft_strlcat.sh — hash verification
# Usage: bash test_c03_ex05_ft_strlcat.sh [source_dir]
set -e

EXERCISE_ID="c03_ex05_ft_strlcat"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C03: ft_strlcat)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strlcat.c" ]; then
    echo "FAILED: File 'ft_strlcat.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_strlcat.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strlcat.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strlcat.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_strlcat.c (use 'while')"
    exit 1
fi

# Check for forbidden strlen/strcat usage
if grep -qE '\b(strlen|strlcat|strcat|strncat)\s*\(' "${SRC_DIR}/ft_strlcat.c" 2>/dev/null; then
    echo "FAILED: Forbidden libc function in ft_strlcat.c"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strlcat.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Normal concat with room ---
echo "Test 1: Normal concat with room..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

unsigned int	ft_strlcat(char *dest, char *src, unsigned int size);

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		ft_putchar(str[i]);
		i++;
	}
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
	char			buf[20];
	unsigned int	ret;

	buf[0] = 'H';
	buf[1] = 'i';
	buf[2] = '\0';
	ret = ft_strlcat(buf, " World", 20);
	ft_putstr(buf);
	ft_putchar(' ');
	ft_putnbr(ret);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_strlcat.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1="Hi World 8"

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Normal concat"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Truncated concat ---
echo "Test 2: Truncated concat (size < dest_len + src_len + 1)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

unsigned int	ft_strlcat(char *dest, char *src, unsigned int size);

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		ft_putchar(str[i]);
		i++;
	}
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
	char			buf[20];
	unsigned int	ret;

	buf[0] = 'A';
	buf[1] = 'B';
	buf[2] = '\0';
	ret = ft_strlcat(buf, "CDEF", 4);
	ft_putstr(buf);
	ft_putchar(' ');
	ft_putnbr(ret);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_strlcat.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="ABC 6"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Truncated concat"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: size <= dest_len ---
echo "Test 3: size <= dest_len..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

unsigned int	ft_strlcat(char *dest, char *src, unsigned int size);

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		ft_putchar(str[i]);
		i++;
	}
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
	char			buf[10];
	unsigned int	ret;

	buf[0] = '1';
	buf[1] = '2';
	buf[2] = '3';
	buf[3] = '\0';
	ret = ft_strlcat(buf, "456789", 2);
	ft_putstr(buf);
	ft_putchar(' ');
	ft_putnbr(ret);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_strlcat.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3="123 8"

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: size <= dest_len"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3

# --- Test 4: size == 0 ---
echo "Test 4: size == 0..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

unsigned int	ft_strlcat(char *dest, char *src, unsigned int size);

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
	char			buf[10];
	unsigned int	ret;

	buf[0] = 'A';
	buf[1] = '\0';
	ret = ft_strlcat(buf, "BCD", 0);
	ft_putnbr(ret);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_strlcat.c" /tmp/${EXERCISE_ID}_main.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4="3"

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: size == 0"
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
