#!/bin/bash
# test_c07_ex00_ft_strdup.sh — hash verification
# Usage: bash test_c07_ex00_ft_strdup.sh [source_dir]
set -e

EXERCISE_ID="c07_ex00_ft_strdup"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C07 ex00: ft_strdup — duplicate string with malloc)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strdup.c" ]; then
    echo "FAILED: File 'ft_strdup.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(|\bstrdup\s*\(|\bstrncpy\s*\(|\bstrlcpy\s*\(' "${SRC_DIR}/ft_strdup.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strdup.c (printf/scanf/puts/strdup/strncpy/strlcpy)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strdup.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_strdup.c (use 'while')"
    exit 1
fi

# Check that malloc is used
if ! grep -qE '\bmalloc\s*\(' "${SRC_DIR}/ft_strdup.c" 2>/dev/null; then
    echo "FAILED: ft_strdup.c must use malloc"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strdup.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Basic strings ---
echo "Test 1: Basic string duplication..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_strdup(char *src);

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
		write(1, &str[i], 1);
		i++;
	}
}

int	main(void)
{
	char	*dup;

	dup = ft_strdup("Hello");
	ft_putstr(dup);
	ft_putchar('\n');
	free(dup);
	dup = ft_strdup("42 Piscine");
	ft_putstr(dup);
	ft_putchar('\n');
	free(dup);
	dup = ft_strdup("a");
	ft_putstr(dup);
	ft_putchar('\n');
	free(dup);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_strdup.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf 'Hello\n42 Piscine\na')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic strings"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Empty string ---
echo "Test 2: Empty string..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_strdup(char *src);

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
		write(1, &str[i], 1);
		i++;
	}
}

int	main(void)
{
	char	*dup;

	dup = ft_strdup("");
	if (dup[0] == '\0')
		write(1, "EMPTY_OK", 8);
	ft_putchar('\n');
	free(dup);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_strdup.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="EMPTY_OK"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Empty string"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: Independence (modifying dup doesn't affect original) ---
echo "Test 3: Dup is independent copy..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_strdup(char *src);

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
}

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

int	main(void)
{
	char	original[] = "Test";
	char	*dup;

	dup = ft_strdup(original);
	dup[0] = 'B';
	ft_putstr(original);
	ft_putchar('\n');
	ft_putstr(dup);
	ft_putchar('\n');
	free(dup);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_strdup.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf 'Test\nBest')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Dup should be independent copy"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3

# --- Test 4: Long string ---
echo "Test 4: Long string..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_strdup(char *src);

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
}

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

int	main(void)
{
	char	*dup;

	dup = ft_strdup("abcdefghijklmnopqrstuvwxyz0123456789");
	ft_putstr(dup);
	ft_putchar('\n');
	free(dup);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_strdup.c" /tmp/${EXERCISE_ID}_main.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4="abcdefghijklmnopqrstuvwxyz0123456789"

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Long string"
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
