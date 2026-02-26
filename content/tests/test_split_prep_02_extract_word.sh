#!/bin/bash
# test_split_prep_02_extract_word.sh — hash verification
# Usage: bash test_split_prep_02_extract_word.sh [source_dir]
set -e

EXERCISE_ID="split_prep_02_extract_word"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C07 scaffold: ft_extract_word — extract first word with malloc)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_extract_word.c" ]; then
    echo "FAILED: File 'ft_extract_word.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_extract_word.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_extract_word.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_extract_word.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_extract_word.c (use 'while')"
    exit 1
fi

# Check for forbidden strncpy/strdup usage
if grep -qE '\bstrncpy\b|\bstrdup\b' "${SRC_DIR}/ft_extract_word.c" 2>/dev/null; then
    echo "FAILED: Forbidden function (strncpy/strdup) in ft_extract_word.c"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_extract_word.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test: All cases ---
echo "Test: All cases..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

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

char	*ft_extract_word(char *str, char c);

int	main(void)
{
	char	*word;

	word = ft_extract_word("hello world", ' ');
	ft_putstr(word);
	ft_putchar('\n');
	free(word);
	word = ft_extract_word("  hello world", ' ');
	ft_putstr(word);
	ft_putchar('\n');
	free(word);
	word = ft_extract_word(",,first,,second", ',');
	ft_putstr(word);
	ft_putchar('\n');
	free(word);
	word = ft_extract_word("oneword", ' ');
	ft_putstr(word);
	ft_putchar('\n');
	free(word);
	word = ft_extract_word("   ", ' ');
	ft_putstr(word);
	ft_putchar('\n');
	free(word);
	word = ft_extract_word("", ' ');
	ft_putstr(word);
	ft_putchar('\n');
	free(word);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_extract_word.c" /tmp/${EXERCISE_ID}_main.c
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf 'hello\nhello\nfirst\noneword\n\n')

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
echo "Code: $HASH"
exit 0
