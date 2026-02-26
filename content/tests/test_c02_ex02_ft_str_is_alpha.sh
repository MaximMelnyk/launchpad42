#!/bin/bash
# test_c02_ex02_ft_str_is_alpha.sh — hash verification
# Usage: bash test_c02_ex02_ft_str_is_alpha.sh [source_dir]
set -e

EXERCISE_ID="c02_ex02_ft_str_is_alpha"
SRC_DIR="${1:-.}"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_str_is_alpha.c" ]; then
    echo "FAILED: File 'ft_str_is_alpha.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_str_is_alpha.c" 2>/dev/null; then
    echo "FAILED: Forbidden function detected (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_str_is_alpha.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop detected (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_str_is_alpha.c" || { echo "NORMINETTE FAILED"; exit 1; }
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

int	ft_str_is_alpha(char *str);

int	main(void)
{
	/* Test 1: all alpha */
	ft_putnbr(ft_str_is_alpha("Hello"));
	write(1, "\n", 1);
	/* Test 2: alpha + digits */
	ft_putnbr(ft_str_is_alpha("Hello42"));
	write(1, "\n", 1);
	/* Test 3: empty string */
	ft_putnbr(ft_str_is_alpha(""));
	write(1, "\n", 1);
	/* Test 4: space in string */
	ft_putnbr(ft_str_is_alpha("abc def"));
	write(1, "\n", 1);
	/* Test 5: mixed case alpha */
	ft_putnbr(ft_str_is_alpha("abcDEFghi"));
	write(1, "\n", 1);
	/* Test 6: single char */
	ft_putnbr(ft_str_is_alpha("A"));
	write(1, "\n", 1);
	/* Test 7: punctuation */
	ft_putnbr(ft_str_is_alpha("hello!"));
	write(1, "\n", 1);
	return (0);
}
TESTEOF

echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_str_is_alpha.c" /tmp/${EXERCISE_ID}_main.c

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf '1\n0\n1\n0\n1\n1\n0')

if [ "$RESULT" == "$EXPECTED" ]; then
    PASS=7
    echo "Test 1 (all alpha 'Hello'): OK"
    echo "Test 2 (alpha+digits 'Hello42'): OK"
    echo "Test 3 (empty string): OK"
    echo "Test 4 (space 'abc def'): OK"
    echo "Test 5 (mixed case 'abcDEFghi'): OK"
    echo "Test 6 (single char 'A'): OK"
    echo "Test 7 (punctuation 'hello!'): OK"
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
    echo "Code: $HASH"
    exit 0
else
    echo "SOME TESTS FAILED"
    exit 1
fi
