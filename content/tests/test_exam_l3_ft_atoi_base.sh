#!/bin/bash
# test_exam_l3_ft_atoi_base.sh — hash verification
# Usage: bash test_exam_l3_ft_atoi_base.sh [source_dir]
set -e

EXERCISE_ID="exam_l3_ft_atoi_base"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 3: ft_atoi_base function)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_atoi_base.c" ]; then
    echo "FAILED: File 'ft_atoi_base.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b|\batoi\b|\bmalloc\b' "${SRC_DIR}/ft_atoi_base.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_atoi_base.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_atoi_base.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_atoi_base.c" || {
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

int	ft_atoi_base(char *str, char *base);

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

void	check(char *str, char *base, int expected, int test_num)
{
	int		result;
	char	d;
	char	e;

	result = ft_atoi_base(str, base);
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
	check("2a", "0123456789abcdef", 42, 1);
	check("101010", "01", 42, 2);
	check("  -2a", "0123456789abcdef", -42, 3);
	check("42", "0123456789", 42, 4);
	check("0", "0123456789", 0, 5);
	check("", "0123456789", 0, 6);
	check("ff", "0123456789abcdef", 255, 7);
	check("  +42", "0123456789", 42, 8);
	check("  --42", "0123456789", 42, 9);
	check("  -+42", "0123456789", -42, 10);
	check("42", "01", 0, 11);
	check("abc", "0", 0, 12);
	check("42", "aa", 0, 13);
	check("42", "0+1", 0, 14);
	check("42", "0-1", 0, 15);
	check("1111", "01", 15, 16);
	check("  \t42", "0123456789", 42, 17);
	check("7f", "0123456789abcdef", 127, 18);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_atoi_base.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK 6:OK 7:OK 8:OK 9:OK 10:OK 11:OK 12:OK 13:OK 14:OK 15:OK 16:OK 17:OK 18:OK "
TOTAL=18

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
