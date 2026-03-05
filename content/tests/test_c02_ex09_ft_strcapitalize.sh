#!/bin/bash
# test_c02_ex09_ft_strcapitalize.sh — hash verification
# Usage: bash test_c02_ex09_ft_strcapitalize.sh [source_dir]
set -e

EXERCISE_ID="c02_ex09_ft_strcapitalize"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_strcapitalize.c" ]; then
    echo "FAILED: File 'ft_strcapitalize.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_strcapitalize.c" 2>/dev/null; then
    echo "FAILED: Forbidden function detected (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strcapitalize.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop detected (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strcapitalize.c" || { echo "NORMINETTE FAILED"; exit 1; }
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

char	*ft_strcapitalize(char *str);

int	main(void)
{
	char	s1[] = "salut, comment tu vas ? 42mots quarante-deux; cinquante+et+un";
	char	s2[] = "HELLO WORLD";
	char	s3[] = "a";
	char	s4[] = "";
	char	s5[] = "123abc 456DEF";
	char	s6[] = "hello---world...test";
	char	*ret;

	ft_putstr(ft_strcapitalize(s1));
	write(1, "\n", 1);
	ft_putstr(ft_strcapitalize(s2));
	write(1, "\n", 1);
	ft_putstr(ft_strcapitalize(s3));
	write(1, "\n", 1);
	ft_putstr(ft_strcapitalize(s4));
	ft_putstr(ft_strcapitalize(s5));
	write(1, "\n", 1);
	ft_putstr(ft_strcapitalize(s6));
	write(1, "\n", 1);
	/* Check return value */
	ret = ft_strcapitalize(s3);
	if (ret == s3)
		write(1, "RET_OK\n", 7);
	else
		write(1, "RET_FAIL\n", 9);
	return (0);
}
TESTEOF

echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_strcapitalize.c" /tmp/${EXERCISE_ID}_main.c

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf 'Salut, Comment Tu Vas ? 42mots Quarante-Deux; Cinquante+Et+Un\nHello World\nA\n123abc 456def\nHello---World...Test\nRET_OK')

if [ "$RESULT" == "$EXPECTED" ]; then
    PASS=6
    echo "Test 1 (42 subject example): OK"
    echo "Test 2 (all upper 'HELLO WORLD'): OK"
    echo "Test 3 (single char 'a'): OK"
    echo "Test 4 (empty + digits prefix): OK"
    echo "Test 5 (multiple separators): OK"
    echo "Test 6 (return value): OK"
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
