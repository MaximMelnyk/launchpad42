#!/bin/bash
# test_exam_l2_ft_strrev.sh — hash verification
# Usage: bash test_exam_l2_ft_strrev.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_ft_strrev"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: ft_strrev function)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strrev.c" ]; then
    echo "FAILED: File 'ft_strrev.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bmalloc\b' "${SRC_DIR}/ft_strrev.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strrev.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strrev.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strrev.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

echo "Compiling..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strrev(char *str);

int	ft_str_eq(char *a, char *b)
{
	int	i;

	i = 0;
	while (a[i] && b[i])
	{
		if (a[i] != b[i])
			return (0);
		i++;
	}
	return (a[i] == b[i]);
}

void	check(char *input, char *expected, int test_num)
{
	char	buf[256];
	char	*ret;
	int		i;
	char	d;
	char	e;

	i = 0;
	while (input[i])
	{
		buf[i] = input[i];
		i++;
	}
	buf[i] = '\0';
	ret = ft_strrev(buf);
	d = '0' + (test_num / 10);
	e = '0' + (test_num % 10);
	if (test_num >= 10)
		write(1, &d, 1);
	write(1, &e, 1);
	if (ft_str_eq(buf, expected) && ret == buf)
		write(1, ":OK ", 4);
	else
		write(1, ":FAIL ", 6);
}

int	main(void)
{
	check("Hello", "olleH", 1);
	check("", "", 2);
	check("a", "a", 3);
	check("ab", "ba", 4);
	check("12345", "54321", 5);
	check("abcdef", "fedcba", 6);
	check("racecar", "racecar", 7);
	check("42", "24", 8);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_strrev.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK 6:OK 7:OK 8:OK "
TOTAL=8

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
