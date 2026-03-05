#!/bin/bash
# test_c02_ex10_ft_strlcpy.sh — hash verification
# Usage: bash test_c02_ex10_ft_strlcpy.sh [source_dir]
set -e

EXERCISE_ID="c02_ex10_ft_strlcpy"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_strlcpy.c" ]; then
    echo "FAILED: File 'ft_strlcpy.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_strlcpy.c" 2>/dev/null; then
    echo "FAILED: Forbidden function detected (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strlcpy.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop detected (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strlcpy.c" || { echo "NORMINETTE FAILED"; exit 1; }
fi

# Create test
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i] != '\0')
	{
		ft_putchar(str[i]);
		i++;
	}
}

void	ft_putnbr(int n)
{
	char	c;

	if (n < 0)
	{
		ft_putchar('-');
		n = -n;
	}
	if (n >= 10)
		ft_putnbr(n / 10);
	c = n % 10 + '0';
	ft_putchar(c);
}

unsigned int	ft_strlcpy(char *dest, char *src, unsigned int size);

int	main(void)
{
	char			dest[20];
	unsigned int	ret;

	/* Test 1: Normal copy, size > src length */
	ret = ft_strlcpy(dest, "Hello", 20);
	ft_putstr(dest);
	ft_putchar(' ');
	ft_putnbr(ret);
	ft_putchar('\n');

	/* Test 2: Truncation, size < src length */
	ret = ft_strlcpy(dest, "Hello, World!", 6);
	ft_putstr(dest);
	ft_putchar(' ');
	ft_putnbr(ret);
	ft_putchar('\n');

	/* Test 3: size = 0, should not copy anything */
	dest[0] = 'X';
	dest[1] = '\0';
	ret = ft_strlcpy(dest, "Hello", 0);
	ft_putnbr(ret);
	ft_putchar(' ');
	/* dest should be unchanged */
	ft_putchar(dest[0]);
	ft_putchar('\n');

	/* Test 4: Empty src */
	ret = ft_strlcpy(dest, "", 5);
	ft_putstr(dest);
	ft_putstr("EMPTY ");
	ft_putnbr(ret);
	ft_putchar('\n');

	/* Test 5: size = 1 (only NUL) */
	ret = ft_strlcpy(dest, "Hello", 1);
	ft_putnbr(dest[0]);
	ft_putchar(' ');
	ft_putnbr(ret);
	ft_putchar('\n');

	return (0);
}
TESTEOF

echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_strlcpy.c" /tmp/${EXERCISE_ID}_main.c

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf 'Hello 5\nHello 13\n5 X\nEMPTY 0\n0 5')

if [ "$RESULT" == "$EXPECTED" ]; then
    PASS=5
    echo "Test 1 (normal copy): OK"
    echo "Test 2 (truncation): OK"
    echo "Test 3 (size=0): OK"
    echo "Test 4 (empty src): OK"
    echo "Test 5 (size=1): OK"
else
    echo "TESTS FAILED"
    echo "  Expected: '$(echo "$EXPECTED" | tr '\n' '|')'"
    echo "  Got:      '$(echo "$RESULT" | tr '\n' '|')'"
    FAIL=1
fi

# Cleanup
rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"

if [ $FAIL -eq 0 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo ""
    echo "ALL TESTS PASSED"
    show_compile_count
    echo "Code: $HASH"
    exit 0
else
    echo "SOME TESTS FAILED"
    exit 1
fi
