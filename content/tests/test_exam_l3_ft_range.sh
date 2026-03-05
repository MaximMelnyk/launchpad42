#!/bin/bash
# test_exam_l3_ft_range.sh — hash verification
# Usage: bash test_exam_l3_ft_range.sh [source_dir]
set -e

EXERCISE_ID="exam_l3_ft_range"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 3: ft_range with malloc)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_range.c" ]; then
    echo "FAILED: File 'ft_range.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/ft_range.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_range.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_range.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_range.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

# --- Build test binary with main ---
echo "Compiling..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

int	*ft_range(int start, int end);

void	ft_putnbr(int n)
{
	char	c;

	if (n == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (n < 0)
	{
		write(1, "-", 1);
		n = -n;
	}
	if (n >= 10)
		ft_putnbr(n / 10);
	c = '0' + (n % 10);
	write(1, &c, 1);
}

void	check_arr(int *arr, int *expected, int len, int test_num)
{
	int		i;
	int		ok;
	char	d;
	char	e;

	d = '0' + (test_num / 10);
	e = '0' + (test_num % 10);
	if (test_num >= 10)
		write(1, &d, 1);
	write(1, &e, 1);
	ok = 1;
	i = 0;
	while (i < len)
	{
		if (arr[i] != expected[i])
		{
			ok = 0;
			break ;
		}
		i++;
	}
	if (ok)
		write(1, ":OK ", 4);
	else
	{
		write(1, ":FAIL ", 6);
	}
}

void	check_null(int *arr, int test_num)
{
	char	d;
	char	e;

	d = '0' + (test_num / 10);
	e = '0' + (test_num % 10);
	if (test_num >= 10)
		write(1, &d, 1);
	write(1, &e, 1);
	if (arr == NULL)
		write(1, ":OK ", 4);
	else
		write(1, ":FAIL ", 6);
}

int	main(void)
{
	int	*r;
	int	e1[] = {0, 1, 2, 3, 4};
	int	e2[] = {5, 4, 3, 2, 1};
	int	e3[] = {-2, -1, 0, 1};
	int	e4[] = {1};
	int	e5[] = {-1};
	int	e6[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

	r = ft_range(0, 5);
	check_arr(r, e1, 5, 1);
	free(r);
	r = ft_range(5, 0);
	check_arr(r, e2, 5, 2);
	free(r);
	r = ft_range(-2, 2);
	check_arr(r, e3, 4, 3);
	free(r);
	r = ft_range(3, 3);
	check_null(r, 4);
	r = ft_range(1, 2);
	check_arr(r, e4, 1, 5);
	free(r);
	r = ft_range(0, -1);
	check_arr(r, e5, 1, 6);
	free(r);
	r = ft_range(0, 10);
	check_arr(r, e6, 10, 7);
	free(r);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_range.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK 6:OK 7:OK "
TOTAL=7

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  All ${TOTAL} cases PASS"
    PASS=$TOTAL
else
    echo "  Output: '$RESULT'"
    PASS=$(echo "$RESULT" | grep -o ":OK" | wc -l)
    FAIL=$((TOTAL - PASS))
    echo "  $PASS passed, $FAIL failed"
fi

rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c

if [ $FAIL -ne 0 ]; then
    echo ""
    echo "TESTS FAILED: $FAIL failed, $PASS passed"
    exit 1
fi

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
