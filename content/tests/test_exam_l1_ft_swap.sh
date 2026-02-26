#!/bin/bash
# test_exam_l1_ft_swap.sh — hash verification
# Usage: bash test_exam_l1_ft_swap.sh [source_dir]
set -e

EXERCISE_ID="exam_l1_ft_swap"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 1: ft_swap function)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_swap.c" ]; then
    echo "FAILED: File 'ft_swap.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b' "${SRC_DIR}/ft_swap.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_swap.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_swap.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_swap.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

# --- All tests in one binary ---
echo "Compiling tests..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_swap(int *a, int *b);

void	ft_putnbr(int n)
{
	char	c;

	if (n < 0)
	{
		write(1, "-", 1);
		if (n == -2147483648)
		{
			write(1, "2147483648", 10);
			return ;
		}
		n = -n;
	}
	if (n >= 10)
		ft_putnbr(n / 10);
	c = '0' + (n % 10);
	write(1, &c, 1);
}

int	main(void)
{
	int	a;
	int	b;

	/* Test 1: Basic swap */
	a = 42;
	b = 21;
	ft_swap(&a, &b);
	if (a == 21 && b == 42)
		write(1, "1:OK ", 5);
	else
		write(1, "1:FAIL ", 7);

	/* Test 2: Negative numbers */
	a = -5;
	b = 10;
	ft_swap(&a, &b);
	if (a == 10 && b == -5)
		write(1, "2:OK ", 5);
	else
		write(1, "2:FAIL ", 7);

	/* Test 3: Same values */
	a = 7;
	b = 7;
	ft_swap(&a, &b);
	if (a == 7 && b == 7)
		write(1, "3:OK ", 5);
	else
		write(1, "3:FAIL ", 7);

	/* Test 4: Zero */
	a = 0;
	b = 100;
	ft_swap(&a, &b);
	if (a == 100 && b == 0)
		write(1, "4:OK ", 5);
	else
		write(1, "4:FAIL ", 7);

	/* Test 5: Large values */
	a = 2147483647;
	b = -2147483648;
	ft_swap(&a, &b);
	if (a == -2147483648 && b == 2147483647)
		write(1, "5:OK ", 5);
	else
		write(1, "5:FAIL ", 7);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_swap.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK "

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  All 5 cases PASS"
    PASS=5
else
    echo "  Output: '$RESULT'"
    PASS=$(echo "$RESULT" | grep -o ":OK" | wc -l)
    FAIL=$((5 - PASS))
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
