#!/bin/bash
# test_exam_l2_ft_atoi.sh — hash verification
# Usage: bash test_exam_l2_ft_atoi.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_ft_atoi"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: ft_atoi function)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_atoi.c" ]; then
    echo "FAILED: File 'ft_atoi.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\batoi\b' "${SRC_DIR}/ft_atoi.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_atoi.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_atoi.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_atoi.c" || {
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

int	ft_atoi(char *str);

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

void	check(char *str, int expected, int test_num)
{
	int		result;
	char	d;
	char	e;

	result = ft_atoi(str);
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
	check("42", 42, 1);
	check("-42", -42, 2);
	check("   42", 42, 3);
	check("  +42", 42, 4);
	check("  -42", -42, 5);
	check("0", 0, 6);
	check("abc", 0, 7);
	check("123abc456", 123, 8);
	check("  \t  567", 567, 9);
	check("2147483647", 2147483647, 10);
	check("-2147483648", -2147483648, 11);
	check("   +0", 0, 12);
	check("", 0, 13);
	check("+-42", 0, 14);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_atoi.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK 6:OK 7:OK 8:OK 9:OK 10:OK 11:OK 12:OK 13:OK 14:OK "
TOTAL=14

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
echo "Code: $HASH"
exit 0
