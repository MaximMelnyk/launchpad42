#!/bin/bash
# test_c02_ex07_ft_strupcase.sh — hash verification
# Usage: bash test_c02_ex07_ft_strupcase.sh [source_dir]
set -e

EXERCISE_ID="c02_ex07_ft_strupcase"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_strupcase.c" ]; then
    echo "FAILED: File 'ft_strupcase.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_strupcase.c" 2>/dev/null; then
    echo "FAILED: Forbidden function detected (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strupcase.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop detected (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strupcase.c" || { echo "NORMINETTE FAILED"; exit 1; }
fi

# Create test
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i] != '\0')
		write(1, &str[i++], 1);
}

char	*ft_strupcase(char *str);

int	main(void)
{
	char	s1[] = "Hello, World!";
	char	s2[] = "abc123def";
	char	s3[] = "ALREADY UP";
	char	s4[] = "";
	char	s5[] = "a";
	char	*ret;

	ft_putstr(ft_strupcase(s1));
	write(1, "\n", 1);
	ft_putstr(ft_strupcase(s2));
	write(1, "\n", 1);
	ft_putstr(ft_strupcase(s3));
	write(1, "\n", 1);
	ft_putstr(ft_strupcase(s4));
	write(1, "END\n", 4);
	/* Check return value */
	ret = ft_strupcase(s5);
	if (ret == s5)
		write(1, "RET_OK\n", 7);
	else
		write(1, "RET_FAIL\n", 9);
	return (0);
}
TESTEOF

echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_strupcase.c" /tmp/${EXERCISE_ID}_main.c

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf 'HELLO, WORLD!\nABC123DEF\nALREADY UP\nEND\nRET_OK')

if [ "$RESULT" == "$EXPECTED" ]; then
    PASS=5
    echo "Test 1 (mixed case): OK"
    echo "Test 2 (lower+digits): OK"
    echo "Test 3 (already upper): OK"
    echo "Test 4 (empty string): OK"
    echo "Test 5 (return value): OK"
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
