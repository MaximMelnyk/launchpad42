#!/bin/bash
# test_c08_ex04_ft_strs_to_tab.sh — hash verification
# Usage: bash test_c08_ex04_ft_strs_to_tab.sh [source_dir]
set -e

EXERCISE_ID="c08_ex04_ft_strs_to_tab"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C08 ex04: ft_strs_to_tab — convert strings to struct array)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strs_to_tab.c" ]; then
    echo "FAILED: File 'ft_strs_to_tab.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(|\bstrdup\s*\(|\bstrlen\s*\(|\bstrcpy\s*\(' "${SRC_DIR}/ft_strs_to_tab.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strs_to_tab.c (printf/scanf/puts/strdup/strlen/strcpy)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strs_to_tab.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Check that malloc is used
if ! grep -qE '\bmalloc\s*\(' "${SRC_DIR}/ft_strs_to_tab.c" 2>/dev/null; then
    echo "FAILED: ft_strs_to_tab.c must use malloc"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strs_to_tab.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Basic strings ---
echo ""
echo "Test 1: Basic 3-string array..."

cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

struct s_stock_str
{
	int		size;
	char	*str;
	char	*copy;
};

struct s_stock_str	*ft_strs_to_tab(int ac, char **av);

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
	char	c;

	if (nb < 0)
	{
		write(1, "-", 1);
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	c = (nb % 10) + '0';
	write(1, &c, 1);
}

int	main(void)
{
	struct s_stock_str	*tab;
	char				*args[] = {"Hello", "42", "Piscine"};
	int					i;

	tab = ft_strs_to_tab(3, args);
	if (!tab)
	{
		ft_putstr("NULL\n");
		return (1);
	}
	i = 0;
	while (i < 3)
	{
		ft_putstr(tab[i].str);
		ft_putchar(' ');
		ft_putnbr(tab[i].size);
		ft_putchar(' ');
		ft_putstr(tab[i].copy);
		ft_putchar('\n');
		free(tab[i].copy);
		i++;
	}
	free(tab);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_strs_to_tab.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf 'Hello 5 Hello\n42 2 42\nPiscine 7 Piscine')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic 3-string array"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 2: Single string ---
echo "Test 2: Single string..."

cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

struct s_stock_str
{
	int		size;
	char	*str;
	char	*copy;
};

struct s_stock_str	*ft_strs_to_tab(int ac, char **av);

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
	char	c;

	if (nb >= 10)
		ft_putnbr(nb / 10);
	c = (nb % 10) + '0';
	write(1, &c, 1);
}

int	main(void)
{
	struct s_stock_str	*tab;
	char				*args[] = {"Test"};

	tab = ft_strs_to_tab(1, args);
	if (!tab)
	{
		ft_putstr("NULL\n");
		return (1);
	}
	ft_putstr(tab[0].str);
	write(1, " ", 1);
	ft_putnbr(tab[0].size);
	write(1, " ", 1);
	ft_putstr(tab[0].copy);
	write(1, "\n", 1);
	free(tab[0].copy);
	free(tab);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_strs_to_tab.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="Test 4 Test"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Single string"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 3: Empty string in array ---
echo "Test 3: Empty string in array..."

cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

struct s_stock_str
{
	int		size;
	char	*str;
	char	*copy;
};

struct s_stock_str	*ft_strs_to_tab(int ac, char **av);

void	ft_putnbr(int nb)
{
	char	c;

	if (nb >= 10)
		ft_putnbr(nb / 10);
	c = (nb % 10) + '0';
	write(1, &c, 1);
}

int	main(void)
{
	struct s_stock_str	*tab;
	char				*args[] = {"", "a", ""};

	tab = ft_strs_to_tab(3, args);
	if (!tab)
	{
		write(1, "NULL\n", 5);
		return (1);
	}
	ft_putnbr(tab[0].size);
	write(1, " ", 1);
	ft_putnbr(tab[1].size);
	write(1, " ", 1);
	ft_putnbr(tab[2].size);
	write(1, "\n", 1);
	free(tab[0].copy);
	free(tab[1].copy);
	free(tab[2].copy);
	free(tab);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_strs_to_tab.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3="0 1 0"

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Empty string in array"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 4: Copy is independent from original ---
echo "Test 4: Copy independence..."

cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

struct s_stock_str
{
	int		size;
	char	*str;
	char	*copy;
};

struct s_stock_str	*ft_strs_to_tab(int ac, char **av);

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

int	main(void)
{
	struct s_stock_str	*tab;
	char				arg1[] = "abc";
	char				*args[] = {arg1};

	tab = ft_strs_to_tab(1, args);
	if (!tab)
	{
		write(1, "NULL\n", 5);
		return (1);
	}
	tab[0].copy[0] = 'X';
	ft_putstr(tab[0].str);
	write(1, " ", 1);
	ft_putstr(tab[0].copy);
	write(1, "\n", 1);
	free(tab[0].copy);
	free(tab);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_strs_to_tab.c" /tmp/${EXERCISE_ID}_main.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4="abc Xbc"

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Copy should be independent from str"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# Cleanup
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
