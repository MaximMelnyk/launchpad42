#!/bin/bash
# test_exam_l2_reverse_bits.sh — hash verification
# Usage: bash test_exam_l2_reverse_bits.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_reverse_bits"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Reverse bits of unsigned char)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/reverse_bits.c" ]; then
    echo "FAILED: File 'reverse_bits.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b' "${SRC_DIR}/reverse_bits.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in reverse_bits.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/reverse_bits.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/reverse_bits.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

echo "Compiling..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

unsigned char	reverse_bits(unsigned char octet);

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

	result = reverse_bits(input);
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
	check(0, 0, 1);         /* 00000000 -> 00000000 */
	check(255, 255, 2);     /* 11111111 -> 11111111 */
	check(1, 128, 3);       /* 00000001 -> 10000000 */
	check(128, 1, 4);       /* 10000000 -> 00000001 */
	check(65, 130, 5);      /* 01000001 -> 10000010 */
	check(42, 84, 6);       /* 00101010 -> 01010100 */
	check(170, 85, 7);      /* 10101010 -> 01010101 */
	check(85, 170, 8);      /* 01010101 -> 10101010 */
	check(240, 15, 9);      /* 11110000 -> 00001111 */
	check(15, 240, 10);     /* 00001111 -> 11110000 */
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/reverse_bits.c" /tmp/${EXERCISE_ID}_main.c
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
    show_compile_count
echo "Code: $HASH"
exit 0
