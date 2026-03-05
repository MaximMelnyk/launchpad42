#!/bin/bash
# test_exam_l3_lcm.sh — hash verification
# Usage: bash test_exam_l3_lcm.sh [source_dir]
set -e

EXERCISE_ID="exam_l3_lcm"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 3: Least Common Multiple)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/lcm.c" ]; then
    echo "FAILED: File 'lcm.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b|\bmalloc\b' "${SRC_DIR}/lcm.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in lcm.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/lcm.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/lcm.c" || {
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

unsigned int	lcm(unsigned int a, unsigned int b);

void	ft_putnbr_u(unsigned int n)
{
	char	c;

	if (n >= 10)
		ft_putnbr_u(n / 10);
	c = '0' + (n % 10);
	write(1, &c, 1);
}

void	check(unsigned int a, unsigned int b, unsigned int expected, int t)
{
	unsigned int	result;
	char			d;
	char			e;

	result = lcm(a, b);
	d = '0' + (t / 10);
	e = '0' + (t % 10);
	if (t >= 10)
		write(1, &d, 1);
	write(1, &e, 1);
	if (result == expected)
		write(1, ":OK ", 4);
	else
	{
		write(1, ":FAIL(", 6);
		ft_putnbr_u(result);
		write(1, "!=", 2);
		ft_putnbr_u(expected);
		write(1, ") ", 2);
	}
}

int	main(void)
{
	check(6, 4, 12, 1);
	check(3, 5, 15, 2);
	check(0, 5, 0, 3);
	check(5, 0, 0, 4);
	check(0, 0, 0, 5);
	check(12, 18, 36, 6);
	check(1, 1, 1, 7);
	check(7, 7, 7, 8);
	check(10, 15, 30, 9);
	check(42, 14, 42, 10);
	check(1, 100, 100, 11);
	check(17, 13, 221, 12);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/lcm.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK 6:OK 7:OK 8:OK 9:OK 10:OK 11:OK 12:OK "
TOTAL=12

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
