#!/bin/bash
# test_exam_l4_ft_itoa.sh — hash verification
# Usage: bash test_exam_l4_ft_itoa.sh [source_dir]
set -e

EXERCISE_ID="exam_l4_ft_itoa"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 4: ft_itoa — int to malloc'd string)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_itoa.c" ]; then
    echo "FAILED: File 'ft_itoa.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bsprintf\b|\bitoa\b' "${SRC_DIR}/ft_itoa.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_itoa.c"
    exit 1
fi

# Check that malloc is used
if ! grep -qE '\bmalloc\b' "${SRC_DIR}/ft_itoa.c" 2>/dev/null; then
    echo "FAILED: malloc not found in ft_itoa.c (required)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_itoa.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_itoa.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

echo "Compiling..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_itoa(int nbr);

int	ft_strcmp(char *s1, char *s2)
{
	int	i;

	i = 0;
	while (s1[i] && s1[i] == s2[i])
		i++;
	return ((unsigned char)s1[i] - (unsigned char)s2[i]);
}

void	check(int nbr, char *expected, int test_num)
{
	char	*result;
	char	d;
	char	e;

	result = ft_itoa(nbr);
	d = '0' + (test_num / 10);
	e = '0' + (test_num % 10);
	if (test_num >= 10)
		write(1, &d, 1);
	write(1, &e, 1);
	if (result == (void *)0)
	{
		write(1, ":FAIL(NULL) ", 12);
		return ;
	}
	if (ft_strcmp(result, expected) == 0)
		write(1, ":OK ", 4);
	else
	{
		write(1, ":FAIL(", 6);
		/* write the result string length manually */
		{
			int len;

			len = 0;
			while (result[len])
				len++;
			write(1, result, len);
		}
		write(1, ") ", 2);
	}
	free(result);
}

int	main(void)
{
	check(0, "0", 1);
	check(42, "42", 2);
	check(-42, "-42", 3);
	check(2147483647, "2147483647", 4);
	check(-2147483648, "-2147483648", 5);
	check(1, "1", 6);
	check(-1, "-1", 7);
	check(100, "100", 8);
	check(-100, "-100", 9);
	check(9, "9", 10);
	check(-9, "-9", 11);
	check(1000000, "1000000", 12);
	check(123456789, "123456789", 13);
	check(-999, "-999", 14);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_itoa.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK 6:OK 7:OK 8:OK 9:OK 10:OK 11:OK 12:OK 13:OK 14:OK "
TOTAL=14

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

if [ $FAIL -ne 0 ] || [ "$RESULT" != "$EXPECTED" ]; then
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
