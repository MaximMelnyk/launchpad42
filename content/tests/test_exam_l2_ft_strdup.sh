#!/bin/bash
# test_exam_l2_ft_strdup.sh — hash verification
# Usage: bash test_exam_l2_ft_strdup.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_ft_strdup"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: ft_strdup function)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strdup.c" ]; then
    echo "FAILED: File 'ft_strdup.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bstrdup\b|\bstrlen\b|\bstrcpy\b' "${SRC_DIR}/ft_strdup.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strdup.c"
    exit 1
fi

# Check that malloc is used
if ! grep -qE '\bmalloc\b' "${SRC_DIR}/ft_strdup.c" 2>/dev/null; then
    echo "FAILED: malloc not found in ft_strdup.c (required)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strdup.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strdup.c" || {
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

char	*ft_strdup(char *src);

void	check(char *src, int test_num)
{
	char	*dup;
	int		i;
	int		ok;
	char	d;
	char	e;

	dup = ft_strdup(src);
	d = '0' + (test_num / 10);
	e = '0' + (test_num % 10);
	if (test_num >= 10)
		write(1, &d, 1);
	write(1, &e, 1);
	if (dup == (void *)0)
	{
		write(1, ":FAIL(NULL) ", 12);
		return ;
	}
	ok = 1;
	i = 0;
	while (src[i])
	{
		if (dup[i] != src[i])
			ok = 0;
		i++;
	}
	if (dup[i] != '\0')
		ok = 0;
	/* Check it is a different pointer */
	if (dup == src)
		ok = 0;
	if (ok)
		write(1, ":OK ", 4);
	else
		write(1, ":FAIL ", 6);
	free(dup);
}

int	main(void)
{
	check("hello", 1);
	check("", 2);
	check("42", 3);
	check("abcdefghijklmnopqrstuvwxyz", 4);
	check("a", 5);
	check("Hello World!", 6);
	check("piscine 42 paris", 7);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_strdup.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:OK 2:OK 3:OK 4:OK 5:OK 6:OK 7:OK "
TOTAL=7

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
