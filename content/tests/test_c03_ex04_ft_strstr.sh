#!/bin/bash
# test_c03_ex04_ft_strstr.sh — hash verification
# Usage: bash test_c03_ex04_ft_strstr.sh [source_dir]
set -e

EXERCISE_ID="c03_ex04_ft_strstr"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C03: ft_strstr)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strstr.c" ]; then
    echo "FAILED: File 'ft_strstr.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_strstr.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strstr.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strstr.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_strstr.c (use 'while')"
    exit 1
fi

# Check for forbidden strstr usage
if grep -qE '\bstrstr\s*\(' "${SRC_DIR}/ft_strstr.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'strstr' in ft_strstr.c"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strstr.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Found at end ---
echo "Test 1: Found at end..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strstr(char *str, char *to_find);

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

int	main(void)
{
	char	*r;

	r = ft_strstr("Hello World", "World");
	if (r)
		ft_putstr(r);
	else
		ft_putstr("(null)");
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_strstr.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1="World"

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Found at end"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Not found ---
echo "Test 2: Not found..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strstr(char *str, char *to_find);

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

int	main(void)
{
	char	*r;

	r = ft_strstr("Hello World", "xyz");
	if (r)
		ft_putstr("FAIL: should be null");
	else
		ft_putstr("OK");
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_strstr.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="OK"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Not found test"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: Empty to_find ---
echo "Test 3: Empty to_find..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strstr(char *str, char *to_find);

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

int	main(void)
{
	char	*r;

	r = ft_strstr("Hello World", "");
	if (r)
		ft_putstr(r);
	else
		ft_putstr("(null)");
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_strstr.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3="Hello World"

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Empty to_find test"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3

# --- Test 4: Full integration ---
echo "Test 4: Full integration..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strstr(char *str, char *to_find);

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

int	main(void)
{
	char	*r;

	r = ft_strstr("Hello World", "World");
	ft_putstr(r ? r : "(null)");
	ft_putchar('\n');
	r = ft_strstr("Hello World", "lo W");
	ft_putstr(r ? r : "(null)");
	ft_putchar('\n');
	r = ft_strstr("Hello World", "xyz");
	ft_putstr(r ? r : "(null)");
	ft_putchar('\n');
	r = ft_strstr("Hello World", "");
	ft_putstr(r ? r : "(null)");
	ft_putchar('\n');
	r = ft_strstr("aaabaaab", "aaab");
	ft_putstr(r ? r : "(null)");
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_strstr.c" /tmp/${EXERCISE_ID}_main.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4=$(printf 'World\nlo World\n(null)\nHello World\naaabaaab')

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Full integration"
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
    show_compile_count
echo "Code: $HASH"
exit 0
