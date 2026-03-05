#!/bin/bash
# test_c07_ex05_ft_split.sh — hash verification
# Usage: bash test_c07_ex05_ft_split.sh [source_dir]
set -e

EXERCISE_ID="c07_ex05_ft_split"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C07 ex05: ft_split — the great filter)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_split.c" ]; then
    echo "FAILED: File 'ft_split.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_split.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_split.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_split.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_split.c (use 'while')"
    exit 1
fi

# Check for forbidden strtok/strsep usage
if grep -qE '\bstrtok\b|\bstrsep\b' "${SRC_DIR}/ft_split.c" 2>/dev/null; then
    echo "FAILED: Forbidden function (strtok/strsep) in ft_split.c"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_split.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Basic cases ---
echo "Test 1: Basic split cases..."
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

char	**ft_split(char *str, char *charset);

void	print_split(char **result)
{
	int	i;

	i = 0;
	if (!result)
	{
		ft_putstr("NULL");
		ft_putchar('\n');
		return ;
	}
	while (result[i])
	{
		ft_putchar('[');
		ft_putstr(result[i]);
		ft_putchar(']');
		i++;
	}
	ft_putchar('\n');
	ft_putnbr(i);
	ft_putchar('\n');
}

void	free_split(char **result)
{
	int	i;

	if (!result)
		return ;
	i = 0;
	while (result[i])
	{
		free(result[i]);
		i++;
	}
	free(result);
}

int	main(void)
{
	char	**r;

	r = ft_split("hello world test", " ");
	print_split(r);
	free_split(r);
	r = ft_split("***hello**world***test**", "*");
	print_split(r);
	free_split(r);
	r = ft_split("hello world\ttab", " \t");
	print_split(r);
	free_split(r);
	r = ft_split("", " ");
	print_split(r);
	free_split(r);
	r = ft_split("   ", " ");
	print_split(r);
	free_split(r);
	r = ft_split("one", " ");
	print_split(r);
	free_split(r);
	r = ft_split("a,b;c.d", ",;.");
	print_split(r);
	free_split(r);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_split.c" /tmp/${EXERCISE_ID}_main.c
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf '[hello][world][test]\n3\n[hello][world][test]\n3\n[hello][world][tab]\n3\n\n0\n\n0\n[one]\n1\n[a][b][c][d]\n4')

if [ "$RESULT" != "$EXPECTED" ]; then
    echo "FAILED"
    echo "Expected:"
    echo "$EXPECTED"
    echo "Got:"
    echo "$RESULT"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 2: Edge cases ---
echo "Test 2: Edge cases..."
cat > /tmp/${EXERCISE_ID}_edge.c << 'TESTEOF'
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

char	**ft_split(char *str, char *charset);

void	free_split(char **result)
{
	int	i;

	if (!result)
		return ;
	i = 0;
	while (result[i])
	{
		free(result[i]);
		i++;
	}
	free(result);
}

int	main(void)
{
	char	**r;

	/* Single char */
	r = ft_split("x", " ");
	if (r && r[0])
		ft_putstr(r[0]);
	ft_putchar('\n');
	free_split(r);
	/* Delimiter only is charset */
	r = ft_split("abcabc", "abc");
	if (r && r[0] == NULL)
		ft_putstr("EMPTY");
	ft_putchar('\n');
	/* NULL termination check */
	r = ft_split("a b", " ");
	if (r && r[0] && r[1] && r[2] == NULL)
		ft_putstr("NULL_TERM_OK");
	ft_putchar('\n');
	free_split(r);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_edge_test \
    "${SRC_DIR}/ft_split.c" /tmp/${EXERCISE_ID}_edge.c
RESULT2=$(/tmp/${EXERCISE_ID}_edge_test)
EXPECTED2=$(printf 'x\nEMPTY\nNULL_TERM_OK')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c /tmp/${EXERCISE_ID}_edge_test /tmp/${EXERCISE_ID}_edge.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c /tmp/${EXERCISE_ID}_edge_test /tmp/${EXERCISE_ID}_edge.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
