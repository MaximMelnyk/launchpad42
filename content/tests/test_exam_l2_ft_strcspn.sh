#!/bin/bash
# test_exam_l2_ft_strcspn.sh — hash verification
# Usage: bash test_exam_l2_ft_strcspn.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_ft_strcspn"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: ft_strcspn function)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strcspn.c" ]; then
    echo "FAILED: File 'ft_strcspn.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bstrcspn\b' "${SRC_DIR}/ft_strcspn.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strcspn.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strcspn.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strcspn.c" || {
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

size_t	ft_strcspn(const char *s, const char *reject);

void	ft_putnbr(int n)
{
	char	c;

	if (n >= 10)
		ft_putnbr(n / 10);
	c = '0' + (n % 10);
	write(1, &c, 1);
}

void	check(const char *s, const char *reject, size_t expected, int test_num)
{
	size_t	result;
	char	d;
	char	e;

	result = ft_strcspn(s, reject);
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
	check("hello", "ol", 2, 1);
	check("abcdef", "dc", 2, 2);
	check("hello", "xyz", 5, 3);
	check("hello", "h", 0, 4);
	check("", "abc", 0, 5);
	check("hello", "", 5, 6);
	check("", "", 0, 7);
	check("abcdef", "f", 5, 8);
	check("abcdef", "a", 0, 9);
	check("42 piscine", " ", 2, 10);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_strcspn.c" /tmp/${EXERCISE_ID}_main.c
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
