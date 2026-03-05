#!/bin/bash
# test_c02_ex04_ft_str_is_lowercase.sh — hash verification
# Usage: bash test_c02_ex04_ft_str_is_lowercase.sh [source_dir]
set -e

EXERCISE_ID="c02_ex04_ft_str_is_lowercase"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_str_is_lowercase.c" ]; then
    echo "FAILED: File 'ft_str_is_lowercase.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_str_is_lowercase.c" 2>/dev/null; then
    echo "FAILED: Forbidden function detected (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_str_is_lowercase.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop detected (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_str_is_lowercase.c" || { echo "NORMINETTE FAILED"; exit 1; }
fi

# Create test
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_putnbr(int n)
{
	char	c;

	if (n >= 10)
		ft_putnbr(n / 10);
	c = n % 10 + '0';
	write(1, &c, 1);
}

int	ft_str_is_lowercase(char *str);

int	main(void)
{
	ft_putnbr(ft_str_is_lowercase("hello"));
	write(1, "\n", 1);
	ft_putnbr(ft_str_is_lowercase("Hello"));
	write(1, "\n", 1);
	ft_putnbr(ft_str_is_lowercase(""));
	write(1, "\n", 1);
	ft_putnbr(ft_str_is_lowercase("abc123"));
	write(1, "\n", 1);
	ft_putnbr(ft_str_is_lowercase("abcdef"));
	write(1, "\n", 1);
	ft_putnbr(ft_str_is_lowercase("abc def"));
	write(1, "\n", 1);
	ft_putnbr(ft_str_is_lowercase("z"));
	write(1, "\n", 1);
	return (0);
}
TESTEOF

echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_str_is_lowercase.c" /tmp/${EXERCISE_ID}_main.c

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf '1\n0\n1\n0\n1\n0\n1')

if [ "$RESULT" == "$EXPECTED" ]; then
    PASS=7
    echo "Test 1 (all lower 'hello'): OK"
    echo "Test 2 (mixed case 'Hello'): OK"
    echo "Test 3 (empty string): OK"
    echo "Test 4 (lower+digits 'abc123'): OK"
    echo "Test 5 (all lower 'abcdef'): OK"
    echo "Test 6 (space 'abc def'): OK"
    echo "Test 7 (single 'z'): OK"
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
