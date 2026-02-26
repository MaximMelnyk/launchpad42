#!/bin/bash
# test_exam_l4_ft_split.sh — hash verification
# Usage: bash test_exam_l4_ft_split.sh [source_dir]
set -e

EXERCISE_ID="exam_l4_ft_split"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 4: ft_split — split string by whitespace)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_split.c" ]; then
    echo "FAILED: File 'ft_split.c' not found"
    exit 1
fi

# Check for forbidden functions (allow malloc only)
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bstrtok\b|\bstrsep\b' "${SRC_DIR}/ft_split.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_split.c"
    exit 1
fi

# Check that malloc is used
if ! grep -qE '\bmalloc\b' "${SRC_DIR}/ft_split.c" 2>/dev/null; then
    echo "FAILED: malloc not found in ft_split.c (required)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_split.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_split.c" || {
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

char	**ft_split(char *str);

int	ft_strcmp(char *a, char *b)
{
	int	i;

	i = 0;
	while (a[i] && a[i] == b[i])
		i++;
	return ((unsigned char)a[i] - (unsigned char)b[i]);
}

int	ft_strlen(char *s)
{
	int	i;

	i = 0;
	while (s[i])
		i++;
	return (i);
}

void	check(char *input, char **expected, int exp_count, int test_num)
{
	char	**result;
	int		i;
	int		ok;
	char	d;
	char	e;

	result = ft_split(input);
	d = '0' + (test_num / 10);
	e = '0' + (test_num % 10);
	if (test_num >= 10)
		write(1, &d, 1);
	write(1, &e, 1);
	if (result == (void *)0)
	{
		if (exp_count == 0)
			write(1, ":OK ", 4);
		else
			write(1, ":FAIL(NULL) ", 12);
		return ;
	}
	ok = 1;
	i = 0;
	while (i < exp_count)
	{
		if (result[i] == (void *)0)
		{
			ok = 0;
			break ;
		}
		if (ft_strcmp(result[i], expected[i]) != 0)
			ok = 0;
		i++;
	}
	if (result[exp_count] != (void *)0)
		ok = 0;
	if (ok)
		write(1, ":OK ", 4);
	else
	{
		write(1, ":FAIL(", 6);
		i = 0;
		while (result[i])
		{
			write(1, "[", 1);
			write(1, result[i], ft_strlen(result[i]));
			write(1, "]", 1);
			i++;
		}
		write(1, ") ", 2);
	}
	i = 0;
	while (result[i])
	{
		free(result[i]);
		i++;
	}
	free(result);
}

int	main(void)
{
	/* Test 1: simple two words */
	{
		char *exp[] = {"hello", "world"};
		check("hello world", exp, 2, 1);
	}
	/* Test 2: leading/trailing spaces */
	{
		char *exp[] = {"hello", "world", "42"};
		check("  hello  world\t42  ", exp, 3, 2);
	}
	/* Test 3: single word */
	{
		char *exp[] = {"hello"};
		check("hello", exp, 1, 3);
	}
	/* Test 4: empty string */
	{
		check("", (void *)0, 0, 4);
	}
	/* Test 5: only spaces */
	{
		check("     ", (void *)0, 0, 5);
	}
	/* Test 6: only tabs */
	{
		check("\t\t\t", (void *)0, 0, 6);
	}
	/* Test 7: mixed separators */
	{
		char *exp[] = {"a", "b", "c"};
		check("\t a \t b \t c \t", exp, 3, 7);
	}
	/* Test 8: single char */
	{
		char *exp[] = {"X"};
		check("X", exp, 1, 8);
	}
	/* Test 9: many words */
	{
		char *exp[] = {"one", "two", "three", "four", "five"};
		check("one two three four five", exp, 5, 9);
	}
	/* Test 10: tabs only between words */
	{
		char *exp[] = {"abc", "def"};
		check("abc\tdef", exp, 2, 10);
	}
	/* Test 11: NULL input */
	{
		check((void *)0, (void *)0, 0, 11);
	}
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_split.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK 6:OK 7:OK 8:OK 9:OK 10:OK 11:OK "
TOTAL=11

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
