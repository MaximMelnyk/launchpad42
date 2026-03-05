#!/bin/bash
# test_c02_ex01_ft_strncpy.sh — hash verification
# Usage: bash test_c02_ex01_ft_strncpy.sh [source_dir]
set -e

EXERCISE_ID="c02_ex01_ft_strncpy"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_strncpy.c" ]; then
    echo "FAILED: File 'ft_strncpy.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_strncpy.c" 2>/dev/null; then
    echo "FAILED: Forbidden function detected (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strncpy.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop detected (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strncpy.c" || { echo "NORMINETTE FAILED"; exit 1; }
fi

# Test 1: src shorter than n (should pad with '\0')
cat > /tmp/${EXERCISE_ID}_test1.c << 'TESTEOF'
#include <unistd.h>

void	ft_putnbr(int n)
{
	char	c;

	if (n >= 10)
		ft_putnbr(n / 10);
	c = n % 10 + '0';
	write(1, &c, 1);
}

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i] != '\0')
		write(1, &str[i++], 1);
}

char	*ft_strncpy(char *dest, char *src, unsigned int n);

int	main(void)
{
	char	dest[20];
	int		i;

	/* Fill dest with 'X' to check padding */
	i = 0;
	while (i < 20)
		dest[i++] = 'X';
	ft_strncpy(dest, "Hello", 10);
	ft_putstr(dest);
	write(1, "\n", 1);
	/* Check that positions 5-9 are '\0' */
	i = 5;
	while (i < 10)
	{
		ft_putnbr(dest[i]);
		write(1, " ", 1);
		i++;
	}
	write(1, "\n", 1);
	return (0);
}
TESTEOF

echo "Compiling test 1..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_strncpy.c" /tmp/${EXERCISE_ID}_test1.c
RESULT=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED=$(printf 'Hello\n0 0 0 0 0 ')

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "Test 1 (padding with NUL): OK"
    PASS=$((PASS + 1))
else
    echo "Test 1 (padding with NUL): FAILED"
    echo "  Expected: '$EXPECTED'"
    echo "  Got:      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 2: src longer than n (should NOT NUL-terminate)
cat > /tmp/${EXERCISE_ID}_test2.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strncpy(char *dest, char *src, unsigned int n);

int	main(void)
{
	char	dest[20];
	int		i;

	ft_strncpy(dest, "Hello, World!", 5);
	i = 0;
	while (i < 5)
	{
		write(1, &dest[i], 1);
		i++;
	}
	write(1, "\n", 1);
	return (0);
}
TESTEOF

echo "Compiling test 2..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_strncpy.c" /tmp/${EXERCISE_ID}_test2.c
RESULT=$(/tmp/${EXERCISE_ID}_test2)

if [ "$RESULT" == "Hello" ]; then
    echo "Test 2 (truncation): OK"
    PASS=$((PASS + 1))
else
    echo "Test 2 (truncation): FAILED"
    echo "  Expected: 'Hello'"
    echo "  Got:      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 3: n = 0
cat > /tmp/${EXERCISE_ID}_test3.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strncpy(char *dest, char *src, unsigned int n);

int	main(void)
{
	char	dest[10];

	dest[0] = 'A';
	ft_strncpy(dest, "Hello", 0);
	if (dest[0] == 'A')
		write(1, "OK\n", 3);
	else
		write(1, "FAIL\n", 5);
	return (0);
}
TESTEOF

echo "Compiling test 3..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_strncpy.c" /tmp/${EXERCISE_ID}_test3.c
RESULT=$(/tmp/${EXERCISE_ID}_test3)

if [ "$RESULT" == "OK" ]; then
    echo "Test 3 (n=0): OK"
    PASS=$((PASS + 1))
else
    echo "Test 3 (n=0): FAILED"
    FAIL=$((FAIL + 1))
fi

# Test 4: Return value
cat > /tmp/${EXERCISE_ID}_test4.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strncpy(char *dest, char *src, unsigned int n);

int	main(void)
{
	char	dest[20];
	char	*ret;

	ret = ft_strncpy(dest, "test", 10);
	if (ret == dest)
		write(1, "OK\n", 3);
	else
		write(1, "FAIL\n", 5);
	return (0);
}
TESTEOF

echo "Compiling test 4..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_strncpy.c" /tmp/${EXERCISE_ID}_test4.c
RESULT=$(/tmp/${EXERCISE_ID}_test4)

if [ "$RESULT" == "OK" ]; then
    echo "Test 4 (return value): OK"
    PASS=$((PASS + 1))
else
    echo "Test 4 (return value): FAILED"
    FAIL=$((FAIL + 1))
fi

# Cleanup
rm -f /tmp/${EXERCISE_ID}_test{1,2,3,4} /tmp/${EXERCISE_ID}_test{1,2,3,4}.c

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed (total: $((PASS + FAIL)))"

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
