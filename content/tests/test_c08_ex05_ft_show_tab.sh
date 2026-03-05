#!/bin/bash
# test_c08_ex05_ft_show_tab.sh — hash verification
# Usage: bash test_c08_ex05_ft_show_tab.sh [source_dir]
set -e

EXERCISE_ID="c08_ex05_ft_show_tab"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C08 ex05: ft_show_tab — display struct array)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_show_tab.c" ]; then
    echo "FAILED: File 'ft_show_tab.c' not found"
    exit 1
fi

# Check that ft_strs_to_tab.c also exists (needed for combined test)
if [ ! -f "${SRC_DIR}/ft_strs_to_tab.c" ]; then
    echo "FAILED: File 'ft_strs_to_tab.c' not found (needed for testing)"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_show_tab.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_show_tab.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_show_tab.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_show_tab.c" || {
        echo "FAILED: Norminette errors found in ft_show_tab.c"
        exit 1
    }
    norminette "${SRC_DIR}/ft_strs_to_tab.c" || {
        echo "FAILED: Norminette errors found in ft_strs_to_tab.c"
        exit 1
    }
fi

# --- Test 1: Basic output with 3 strings ---
echo ""
echo "Test 1: Basic output with 3 strings..."

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
void				ft_show_tab(struct s_stock_str *par);

int	main(void)
{
	struct s_stock_str	*tab;
	char				*args[] = {"Hello", "42", "Piscine"};

	tab = ft_strs_to_tab(3, args);
	if (tab)
		ft_show_tab(tab);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_strs_to_tab.c" "${SRC_DIR}/ft_show_tab.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf 'Hello\n5\nHello\n42\n2\n42\nPiscine\n7\nPiscine')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic output"
    echo "Expected:"
    echo "$EXPECTED1"
    echo "Got:"
    echo "$RESULT1"
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
void				ft_show_tab(struct s_stock_str *par);

int	main(void)
{
	struct s_stock_str	*tab;
	char				*args[] = {"abc"};

	tab = ft_strs_to_tab(1, args);
	if (tab)
		ft_show_tab(tab);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_strs_to_tab.c" "${SRC_DIR}/ft_show_tab.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf 'abc\n3\nabc')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Single string"
    echo "Expected:"
    echo "$EXPECTED2"
    echo "Got:"
    echo "$RESULT2"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 3: Empty string ---
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
void				ft_show_tab(struct s_stock_str *par);

int	main(void)
{
	struct s_stock_str	*tab;
	char				*args[] = {"", "x"};

	tab = ft_strs_to_tab(2, args);
	if (tab)
		ft_show_tab(tab);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_strs_to_tab.c" "${SRC_DIR}/ft_show_tab.c" /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf '\n0\n\nx\n1\nx')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Empty string in array"
    echo "Expected:"
    echo "$EXPECTED3"
    echo "Got:"
    echo "$RESULT3"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 4: Long string with spaces ---
echo "Test 4: Long string with spaces..."

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
void				ft_show_tab(struct s_stock_str *par);

int	main(void)
{
	struct s_stock_str	*tab;
	char				*args[] = {"Hello World"};

	tab = ft_strs_to_tab(1, args);
	if (tab)
		ft_show_tab(tab);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_strs_to_tab.c" "${SRC_DIR}/ft_show_tab.c" /tmp/${EXERCISE_ID}_main.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4=$(printf 'Hello World\n11\nHello World')

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Long string"
    echo "Expected:"
    echo "$EXPECTED4"
    echo "Got:"
    echo "$RESULT4"
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
