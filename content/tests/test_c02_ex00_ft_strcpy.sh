#!/bin/bash
# test_c02_ex00_ft_strcpy.sh — hash verification
# Usage: bash test_c02_ex00_ft_strcpy.sh [source_dir]
set -e

EXERCISE_ID="c02_ex00_ft_strcpy"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_strcpy.c" ]; then
    echo "FAILED: File 'ft_strcpy.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_strcpy.c" 2>/dev/null; then
    echo "FAILED: Forbidden function detected (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strcpy.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop detected (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strcpy.c" || { echo "NORMINETTE FAILED"; exit 1; }
fi

# Test 1: Basic copy
cat > /tmp/${EXERCISE_ID}_test1.c << 'TESTEOF'
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

char	*ft_strcpy(char *dest, char *src);

int	main(void)
{
	char	dest[50];

	ft_strcpy(dest, "Hello, Piscine!");
	ft_putstr(dest);
	ft_putchar('\n');
	ft_strcpy(dest, "42");
	ft_putstr(dest);
	ft_putchar('\n');
	ft_strcpy(dest, "");
	ft_putstr(dest);
	ft_putstr("EMPTY\n");
	return (0);
}
TESTEOF

echo "Compiling test 1..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_strcpy.c" /tmp/${EXERCISE_ID}_test1.c
RESULT=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED=$(printf 'Hello, Piscine!\n42\nEMPTY')

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "Test 1 (basic copy): OK"
    PASS=$((PASS + 1))
else
    echo "Test 1 (basic copy): FAILED"
    echo "  Expected: '$EXPECTED'"
    echo "  Got:      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 2: Return value check
cat > /tmp/${EXERCISE_ID}_test2.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strcpy(char *dest, char *src);

int	main(void)
{
	char	dest[50];
	char	*ret;

	ret = ft_strcpy(dest, "test");
	if (ret == dest)
		write(1, "OK\n", 3);
	else
		write(1, "FAIL\n", 5);
	return (0);
}
TESTEOF

echo "Compiling test 2..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_strcpy.c" /tmp/${EXERCISE_ID}_test2.c
RESULT=$(/tmp/${EXERCISE_ID}_test2)

if [ "$RESULT" == "OK" ]; then
    echo "Test 2 (return value): OK"
    PASS=$((PASS + 1))
else
    echo "Test 2 (return value): FAILED"
    FAIL=$((FAIL + 1))
fi

# Test 3: Long string
cat > /tmp/${EXERCISE_ID}_test3.c << 'TESTEOF'
#include <unistd.h>

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i] != '\0')
		write(1, &str[i++], 1);
}

char	*ft_strcpy(char *dest, char *src);

int	main(void)
{
	char	dest[200];

	ft_strcpy(dest, "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ");
	ft_putstr(dest);
	write(1, "\n", 1);
	return (0);
}
TESTEOF

echo "Compiling test 3..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_strcpy.c" /tmp/${EXERCISE_ID}_test3.c
RESULT=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED="abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "Test 3 (long string): OK"
    PASS=$((PASS + 1))
else
    echo "Test 3 (long string): FAILED"
    FAIL=$((FAIL + 1))
fi

# Cleanup
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test1.c
rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test2.c
rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_test3.c

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
