#!/bin/bash
# test_exam_l2_ft_is_power_2.sh — hash verification
# Usage: bash test_exam_l2_ft_is_power_2.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_ft_is_power_2"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Check if number is power of 2)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_is_power_2.c" ]; then
    echo "FAILED: File 'ft_is_power_2.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b' "${SRC_DIR}/ft_is_power_2.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_is_power_2.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_is_power_2.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_is_power_2.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

echo "Compiling..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_is_power_2(unsigned int n);

void	ft_putnbr(unsigned int n)
{
	char	c;

	if (n >= 10)
		ft_putnbr(n / 10);
	c = '0' + (n % 10);
	write(1, &c, 1);
}

void	check(unsigned int n, int expected, int test_num)
{
	int		result;
	char	d;
	char	e;

	result = ft_is_power_2(n);
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
		ft_putnbr((unsigned int)result);
		write(1, "!=", 2);
		ft_putnbr((unsigned int)expected);
		write(1, ") ", 2);
	}
}

int	main(void)
{
	check(0, 0, 1);
	check(1, 1, 2);
	check(2, 1, 3);
	check(3, 0, 4);
	check(4, 1, 5);
	check(5, 0, 6);
	check(8, 1, 7);
	check(16, 1, 8);
	check(32, 1, 9);
	check(64, 1, 10);
	check(128, 1, 11);
	check(256, 1, 12);
	check(255, 0, 13);
	check(1024, 1, 14);
	check(1023, 0, 15);
	check(2147483648U, 1, 16);
	check(100, 0, 17);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_is_power_2.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK 6:OK 7:OK 8:OK 9:OK 10:OK 11:OK 12:OK 13:OK 14:OK 15:OK 16:OK 17:OK "
TOTAL=17

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
