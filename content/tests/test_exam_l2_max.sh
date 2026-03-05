#!/bin/bash
# test_exam_l2_max.sh — hash verification
# Usage: bash test_exam_l2_max.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_max"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Find max in int array)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/max.c" ]; then
    echo "FAILED: File 'max.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b' "${SRC_DIR}/max.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in max.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/max.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/max.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

echo "Compiling..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	max(int *tab, unsigned int len);

void	ft_putnbr(int n)
{
	char	c;

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

void	check(int result, int expected, int test_num)
{
	char	d;
	char	e;

	d = '0' + (test_num / 10);
	e = '0' + (test_num % 10);
	if (test_num >= 10)
		write(1, &d, 1);
	write(1, &e, 1);
	if (result == expected)
		write(1, ":OK ", 4);
	else
	{
		write(1, ":FAIL(", 6);
		ft_putnbr(result);
		write(1, "!=", 2);
		ft_putnbr(expected);
		write(1, ") ", 2);
	}
}

int	main(void)
{
	int	a1[] = {1, 5, 3, 9, 2};
	int	a2[] = {-5, -1, -3};
	int	a3[] = {42};
	int	a4[] = {0, 0, 0};
	int	a5[] = {-2147483647, 0, 2147483647};
	int	a6[] = {10, 9, 8, 7, 6};
	int	a7[] = {1, 2, 3, 4, 5};

	check(max(a1, 5), 9, 1);
	check(max(a2, 3), -1, 2);
	check(max(a3, 1), 42, 3);
	check(max(a4, 3), 0, 4);
	check(max(a5, 3), 2147483647, 5);
	check(max(a6, 5), 10, 6);
	check(max(a7, 5), 5, 7);
	check(max(a1, 0), 0, 8);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/max.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK 6:OK 7:OK 8:OK "
TOTAL=8

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
