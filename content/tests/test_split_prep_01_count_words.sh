#!/bin/bash
# test_split_prep_01_count_words.sh — hash verification
# Usage: bash test_split_prep_01_count_words.sh [source_dir]
set -e

EXERCISE_ID="split_prep_01_count_words"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C07 scaffold: ft_count_words — count words by delimiter)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_count_words.c" ]; then
    echo "FAILED: File 'ft_count_words.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_count_words.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_count_words.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_count_words.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_count_words.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_count_words.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test: All cases ---
echo "Test: All cases..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
	if (nb == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (nb < 0)
	{
		ft_putchar('-');
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}

int	ft_count_words(char *str, char c);

int	main(void)
{
	ft_putnbr(ft_count_words("hello world test", ' '));
	ft_putchar('\n');
	ft_putnbr(ft_count_words("", ' '));
	ft_putchar('\n');
	ft_putnbr(ft_count_words("   ", ' '));
	ft_putchar('\n');
	ft_putnbr(ft_count_words("  hello  world  ", ' '));
	ft_putchar('\n');
	ft_putnbr(ft_count_words("one", ' '));
	ft_putchar('\n');
	ft_putnbr(ft_count_words("a,b,,c,,,d", ','));
	ft_putchar('\n');
	ft_putnbr(ft_count_words("no-delimiters-here", ' '));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_count_words.c" /tmp/${EXERCISE_ID}_main.c
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf '3\n0\n0\n2\n1\n4\n1')

if [ "$RESULT" != "$EXPECTED" ]; then
    echo "FAILED"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$RESULT'"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
