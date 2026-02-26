#!/bin/bash
# test_split_prep_03_word_array.sh — hash verification
# Usage: bash test_split_prep_03_word_array.sh [source_dir]
set -e

EXERCISE_ID="split_prep_03_word_array"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C07 scaffold: ft_word_array — 2-word array with malloc)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_word_array.c" ]; then
    echo "FAILED: File 'ft_word_array.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_word_array.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_word_array.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_word_array.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_word_array.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_word_array.c" || {
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

char	**ft_word_array(char *str, char c);

int	main(void)
{
	char	**result;

	result = ft_word_array("hello world", ' ');
	if (result)
	{
		ft_putstr(result[0]);
		ft_putchar('|');
		ft_putstr(result[1]);
		ft_putchar('\n');
		free(result[0]);
		free(result[1]);
		free(result);
	}
	result = ft_word_array("  first  second  third", ' ');
	if (result)
	{
		ft_putstr(result[0]);
		ft_putchar('|');
		ft_putstr(result[1]);
		ft_putchar('\n');
		free(result[0]);
		free(result[1]);
		free(result);
	}
	result = ft_word_array("only", ' ');
	if (result)
	{
		ft_putstr(result[0]);
		ft_putchar('|');
		ft_putstr(result[1]);
		ft_putchar('\n');
		free(result[0]);
		free(result[1]);
		free(result);
	}
	result = ft_word_array("   ", ' ');
	if (result)
		ft_putstr("ERROR: should be NULL\n");
	else
		ft_putstr("NULL\n");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_word_array.c" /tmp/${EXERCISE_ID}_main.c
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf 'hello|world\nfirst|second\nonly|\nNULL')

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
