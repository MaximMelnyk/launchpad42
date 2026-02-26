#!/bin/bash
# test_exam_l1_ft_putstr.sh — hash verification
# Usage: bash test_exam_l1_ft_putstr.sh [source_dir]
set -e

EXERCISE_ID="exam_l1_ft_putstr"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 1: ft_putstr function)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_putstr.c" ]; then
    echo "FAILED: File 'ft_putstr.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/ft_putstr.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_putstr.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_putstr.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_putstr.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

# --- Test 1: Basic string ---
echo "Test 1: Basic string..."
cat > /tmp/${EXERCISE_ID}_main1.c << 'TESTEOF'
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("Hello World");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_putstr.c" /tmp/${EXERCISE_ID}_main1.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main1.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED="Hello World"
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
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("");
	ft_putstr("after");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_putstr.c" /tmp/${EXERCISE_ID}_main2.c

RESULT=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED="after"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi
rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c

# --- Test 3: Multiple calls ---
echo "Test 3: Multiple calls..."
cat > /tmp/${EXERCISE_ID}_main3.c << 'TESTEOF'
#include <unistd.h>

void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("Hello");
	ft_putstr(" ");
	ft_putstr("42");
	write(1, "\n", 1);
	ft_putstr("Piscine");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_putstr.c" /tmp/${EXERCISE_ID}_main3.c

RESULT=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED=$(printf 'Hello 42\nPiscine')
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi
rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c

# --- Test 4: Special characters ---
echo "Test 4: Special characters..."
cat > /tmp/${EXERCISE_ID}_main4.c << 'TESTEOF'
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("!@#$%^&*()");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_putstr.c" /tmp/${EXERCISE_ID}_main4.c

RESULT=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED='!@#$%^&*()'
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
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
