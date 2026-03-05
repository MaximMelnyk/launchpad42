#!/bin/bash
# test_c07_ex03_ft_strjoin.sh — hash verification
# Usage: bash test_c07_ex03_ft_strjoin.sh [source_dir]
set -e

EXERCISE_ID="c07_ex03_ft_strjoin"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C07 ex03: ft_strjoin — join strings with separator)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strjoin.c" ]; then
    echo "FAILED: File 'ft_strjoin.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(|\bstrcat\s*\(' "${SRC_DIR}/ft_strjoin.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strjoin.c (printf/scanf/puts/strcat)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strjoin.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_strjoin.c (use 'while')"
    exit 1
fi

# Check that malloc is used
if ! grep -qE '\bmalloc\s*\(' "${SRC_DIR}/ft_strjoin.c" 2>/dev/null; then
    echo "FAILED: ft_strjoin.c must use malloc"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strjoin.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Three strings with "-" separator ---
echo "Test 1: Join 3 strings with '-'..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_strjoin(int size, char **strs, char *sep);

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
	char	*strs[3];
	char	*result;

	strs[0] = "Hello";
	strs[1] = "World";
	strs[2] = "42";
	result = ft_strjoin(3, strs, "-");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_strjoin.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1="Hello-World-42"

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Join 3 strings with '-'"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Multi-char separator ---
echo "Test 2: Multi-char separator ', '..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_strjoin(int size, char **strs, char *sep);

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
	char	*strs[3];
	char	*result;

	strs[0] = "Hello";
	strs[1] = "World";
	strs[2] = "42";
	result = ft_strjoin(3, strs, ", ");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_strjoin.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="Hello, World, 42"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Multi-char separator"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: size == 0 returns empty string ---
echo "Test 3: size == 0 returns malloc'd empty string..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_strjoin(int size, char **strs, char *sep);

int	main(void)
{
	char	*strs[1];
	char	*result;

	strs[0] = "unused";
	result = ft_strjoin(0, strs, "-");
	if (result != NULL && result[0] == '\0')
		write(1, "EMPTY_OK", 8);
	else
		write(1, "FAIL", 4);
	write(1, "\n", 1);
	free(result);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_strjoin.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3="EMPTY_OK"

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: size == 0"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3

# --- Test 4: size == 1 (no separator in output) ---
echo "Test 4: size == 1, no separator..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_strjoin(int size, char **strs, char *sep);

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
	char	*strs[1];
	char	*result;

	strs[0] = "Alone";
	result = ft_strjoin(1, strs, "---");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_strjoin.c" /tmp/${EXERCISE_ID}_main.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4="Alone"

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: size == 1"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test4

# --- Test 5: Empty separator ---
echo "Test 5: Empty separator..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_strjoin(int size, char **strs, char *sep);

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
	char	*strs[3];
	char	*result;

	strs[0] = "Hello";
	strs[1] = "World";
	strs[2] = "42";
	result = ft_strjoin(3, strs, "");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test5 \
    "${SRC_DIR}/ft_strjoin.c" /tmp/${EXERCISE_ID}_main.c
RESULT5=$(/tmp/${EXERCISE_ID}_test5)
EXPECTED5="HelloWorld42"

if [ "$RESULT5" != "$EXPECTED5" ]; then
    echo "FAILED: Empty separator"
    echo "Expected: '$EXPECTED5'"
    echo "Got:      '$RESULT5'"
    rm -f /tmp/${EXERCISE_ID}_test5 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test5

# --- Test 6: Empty strings in array ---
echo "Test 6: Empty strings in array..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_strjoin(int size, char **strs, char *sep);

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
	char	*strs[3];
	char	*result;

	strs[0] = "";
	strs[1] = "mid";
	strs[2] = "";
	result = ft_strjoin(3, strs, "-");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test6 \
    "${SRC_DIR}/ft_strjoin.c" /tmp/${EXERCISE_ID}_main.c
RESULT6=$(/tmp/${EXERCISE_ID}_test6)
EXPECTED6="-mid-"

if [ "$RESULT6" != "$EXPECTED6" ]; then
    echo "FAILED: Empty strings in array"
    echo "Expected: '$EXPECTED6'"
    echo "Got:      '$RESULT6'"
    rm -f /tmp/${EXERCISE_ID}_test6 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test6 /tmp/${EXERCISE_ID}_main.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
