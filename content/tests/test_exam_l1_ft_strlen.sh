#!/bin/bash
# test_exam_l1_ft_strlen.sh — hash verification
# Usage: bash test_exam_l1_ft_strlen.sh [source_dir]
set -e

EXERCISE_ID="exam_l1_ft_strlen"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 1: ft_strlen function)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strlen.c" ]; then
    echo "FAILED: File 'ft_strlen.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bstrlen\b' "${SRC_DIR}/ft_strlen.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strlen.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strlen.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strlen.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

# --- Test with all cases in one binary ---
echo "Test: Multiple cases..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_strlen(char *str);

void	ft_putnbr(int n)
{
	char	c;

	if (n >= 10)
		ft_putnbr(n / 10);
	c = '0' + (n % 10);
	write(1, &c, 1);
}

void	check(char *str, int expected, int test_num)
{
	int		result;
	char	num;

	result = ft_strlen(str);
	num = '0' + test_num;
	write(1, &num, 1);
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
	check("Hello", 5, 1);
	check("", 0, 2);
	check("42", 2, 3);
	check("abcdefghijklmnopqrstuvwxyz", 26, 4);
	check("a", 1, 5);
	check("Hello World!", 12, 6);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_strlen.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK 6:OK "

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  All 6 cases PASS"
    PASS=6
else
    echo "  Output: '$RESULT'"
    # Count passes
    PASS=$(echo "$RESULT" | grep -o ":OK" | wc -l)
    FAIL=$((6 - PASS))
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
