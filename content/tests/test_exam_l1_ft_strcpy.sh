#!/bin/bash
# test_exam_l1_ft_strcpy.sh — hash verification
# Usage: bash test_exam_l1_ft_strcpy.sh [source_dir]
set -e

EXERCISE_ID="exam_l1_ft_strcpy"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 1: ft_strcpy function)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_strcpy.c" ]; then
    echo "FAILED: File 'ft_strcpy.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b|\bstrcpy\b|\bstrncpy\b|\bmemcpy\b' "${SRC_DIR}/ft_strcpy.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_strcpy.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strcpy.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strcpy.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

# --- Test 1: Basic copy ---
echo "Test 1: Basic copy..."
cat > /tmp/${EXERCISE_ID}_main1.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strcpy(char *dest, char *src);

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
}

int	main(void)
{
	char	dest[50];

	ft_strcpy(dest, "Hello");
	ft_putstr(dest);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_strcpy.c" /tmp/${EXERCISE_ID}_main1.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main1.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED="Hello"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main1.c

# --- Test 2: Empty string ---
echo "Test 2: Empty string..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strcpy(char *dest, char *src);

int	main(void)
{
	char	dest[50];

	dest[0] = 'X';
	ft_strcpy(dest, "");
	if (dest[0] == '\0')
		write(1, "OK", 2);
	else
		write(1, "FAIL", 4);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_strcpy.c" /tmp/${EXERCISE_ID}_main2.c

RESULT=$(/tmp/${EXERCISE_ID}_test2)
if [ "$RESULT" == "OK" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Empty string not copied correctly"
    ((FAIL++))
fi
rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c

# --- Test 3: Return value ---
echo "Test 3: Return value (should return dest)..."
cat > /tmp/${EXERCISE_ID}_main3.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strcpy(char *dest, char *src);

int	main(void)
{
	char	dest[50];
	char	*ret;

	ret = ft_strcpy(dest, "test");
	if (ret == dest)
		write(1, "OK", 2);
	else
		write(1, "FAIL", 4);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_strcpy.c" /tmp/${EXERCISE_ID}_main3.c

RESULT=$(/tmp/${EXERCISE_ID}_test3)
if [ "$RESULT" == "OK" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: ft_strcpy should return dest pointer"
    ((FAIL++))
fi
rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c

# --- Test 4: Null terminator ---
echo "Test 4: Null terminator copied..."
cat > /tmp/${EXERCISE_ID}_main4.c << 'TESTEOF'
#include <unistd.h>

char	*ft_strcpy(char *dest, char *src);

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
}

int	main(void)
{
	char	dest[50];

	dest[0] = 'A';
	dest[1] = 'B';
	dest[2] = 'C';
	dest[3] = 'D';
	dest[4] = '\0';
	ft_strcpy(dest, "Hi");
	ft_putstr(dest);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_strcpy.c" /tmp/${EXERCISE_ID}_main4.c

RESULT=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED="Hi"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT' (null terminator not copied?)"
    ((FAIL++))
fi
rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main4.c

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
