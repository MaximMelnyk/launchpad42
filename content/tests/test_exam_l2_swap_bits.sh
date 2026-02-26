#!/bin/bash
# test_exam_l2_swap_bits.sh — hash verification
# Usage: bash test_exam_l2_swap_bits.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_swap_bits"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Swap high and low nibbles)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/swap_bits.c" ]; then
    echo "FAILED: File 'swap_bits.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b' "${SRC_DIR}/swap_bits.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in swap_bits.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/swap_bits.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/swap_bits.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

echo "Compiling..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

unsigned char	swap_bits(unsigned char octet);

void	ft_putnbr(int n)
{
	char	c;

	if (n >= 10)
		ft_putnbr(n / 10);
	c = '0' + (n % 10);
	write(1, &c, 1);
}

void	check(unsigned char input, unsigned char expected, int test_num)
{
	unsigned char	result;
	char			d;
	char			e;

	result = swap_bits(input);
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
		ft_putnbr((int)result);
		write(1, "!=", 2);
		ft_putnbr((int)expected);
		write(1, ") ", 2);
	}
}

int	main(void)
{
	check(0, 0, 1);          /* 0000 0000 -> 0000 0000 */
	check(255, 255, 2);      /* 1111 1111 -> 1111 1111 */
	check(65, 20, 3);        /* 0100 0001 -> 0001 0100 */
	check(240, 15, 4);       /* 1111 0000 -> 0000 1111 */
	check(15, 240, 5);       /* 0000 1111 -> 1111 0000 */
	check(1, 16, 6);         /* 0000 0001 -> 0001 0000 */
	check(16, 1, 7);         /* 0001 0000 -> 0000 0001 */
	check(170, 170, 8);      /* 1010 1010 -> 1010 1010 */
	check(42, 162, 9);       /* 0010 1010 -> 1010 0010 */
	check(171, 186, 10);     /* 1010 1011 -> 1011 1010 */
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/swap_bits.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK 6:OK 7:OK 8:OK 9:OK 10:OK "
TOTAL=10

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
