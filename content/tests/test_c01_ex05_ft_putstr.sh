#!/bin/bash
# test_c01_ex05_ft_putstr.sh — hash verification
# Usage: bash test_c01_ex05_ft_putstr.sh [source_dir]
set -e

EXERCISE_ID="c01_ex05_ft_putstr"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C01 ex05: ft_putstr — print string using pointer)"
echo ""

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_putstr.c" ]; then
    echo "FAILED: File 'ft_putstr.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_putstr.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_putstr.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_putstr.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_putstr.c (use 'while')"
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

# --- Test 1: Basic strings ---
echo "Test 1: Basic strings..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("Hello World!");
	ft_putstr("\n");
	ft_putstr("");
	ft_putstr("42\n");
	ft_putstr("Piscine C01\n");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_putstr.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf 'Hello World!\n42\nPiscine C01')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic strings"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c

# --- Test 2: Empty string and concatenation ---
echo "Test 2: Empty string and concatenation..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("abc");
	ft_putstr("");
	ft_putstr("def\n");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_putstr.c" /tmp/${EXERCISE_ID}_main2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="abcdef"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Empty string and concatenation"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c

# --- Test 3: Special characters ---
echo "Test 3: Special characters..."
cat > /tmp/${EXERCISE_ID}_main3.c << 'TESTEOF'
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("tab:\there\n");
	ft_putstr("!@#$%\n");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_putstr.c" /tmp/${EXERCISE_ID}_main3.c

RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf 'tab:\there\n!@#$%%')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Special characters"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
