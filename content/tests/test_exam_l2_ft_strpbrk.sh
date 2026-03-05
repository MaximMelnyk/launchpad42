#!/bin/bash
# test_exam_l2_ft_strpbrk.sh — hash verification
# Usage: bash test_exam_l2_ft_strpbrk.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_ft_strpbrk"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: ft_strpbrk function)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strpbrk.c" ]; then
    echo "FAILED: File 'ft_strpbrk.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bstrpbrk\b' "${SRC_DIR}/ft_strpbrk.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strpbrk.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strpbrk.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strpbrk.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

echo "Compiling..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stddef.h>

char	*ft_strpbrk(const char *s1, const char *s2);

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

void	check_ptr(const char *s1, const char *s2, int exp_offset, int test_num)
{
	char	*result;
	int		ok;
	char	d;
	char	e;

	result = ft_strpbrk(s1, s2);
	d = '0' + (test_num / 10);
	e = '0' + (test_num % 10);
	if (test_num >= 10)
		write(1, &d, 1);
	write(1, &e, 1);
	ok = 0;
	if (exp_offset == -1 && result == NULL)
		ok = 1;
	else if (exp_offset >= 0 && result == s1 + exp_offset)
		ok = 1;
	if (ok)
		write(1, ":OK ", 4);
	else
	{
		write(1, ":FAIL(", 6);
		if (result == NULL)
			write(1, "NULL", 4);
		else
			ft_putnbr((int)(result - s1));
		write(1, "!=", 2);
		ft_putnbr(exp_offset);
		write(1, ") ", 2);
	}
}

int	main(void)
{
	check_ptr("hello", "ol", 2, 1);
	check_ptr("hello", "xyz", -1, 2);
	check_ptr("hello", "h", 0, 3);
	check_ptr("", "abc", -1, 4);
	check_ptr("hello", "", -1, 5);
	check_ptr("", "", -1, 6);
	check_ptr("abcdef", "fed", 3, 7);
	check_ptr("abcdef", "a", 0, 8);
	check_ptr("42paris", "42", 0, 9);
	check_ptr("abcdef", "ghi", -1, 10);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_strpbrk.c" /tmp/${EXERCISE_ID}_main.c
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
