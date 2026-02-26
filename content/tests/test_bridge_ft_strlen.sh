#!/bin/bash
# test_bridge_ft_strlen.sh — hash verification
# Usage: bash test_bridge_ft_strlen.sh [source_dir]
set -e

EXERCISE_ID="bridge_ft_strlen"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Bridge: ft_strlen — return length of string)"
echo ""

# Check source files exist
for f in ft_strlen.c ft_putchar.c ft_putnbr.c; do
    if [ ! -f "${SRC_DIR}/${f}" ]; then
        echo "FAILED: File '${f}' not found"
        exit 1
    fi
done

# Check for forbidden functions
for f in ft_strlen.c ft_putchar.c ft_putnbr.c; do
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

# Check that student doesn't use standard strlen
if grep -qE '#include\s*<string\.h>' "${SRC_DIR}/ft_strlen.c" 2>/dev/null; then
    echo "FAILED: Do not include <string.h> — write your own strlen"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_strlen.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_strlen.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_strlen.c" "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putnbr.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Basic strings ---
echo "Test 1: Basic string lengths..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_putchar(char c);
void	ft_putnbr(int nb);
int		ft_strlen(char *str);

int	main(void)
{
	ft_putnbr(ft_strlen("Hello"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen(""));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("42 Paris Piscine"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("A"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_strlen.c" "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putnbr.c" \
    /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '5\n0\n16\n1')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic string lengths"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c

# --- Test 2: Special characters ---
echo "Test 2: Strings with special characters..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
void	ft_putchar(char c);
void	ft_putnbr(int nb);
int		ft_strlen(char *str);

int	main(void)
{
	ft_putnbr(ft_strlen("abc\tdef"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("  "));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("0123456789"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_strlen.c" "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putnbr.c" \
    /tmp/${EXERCISE_ID}_main2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '7\n2\n10')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Special characters test"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
