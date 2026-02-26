#!/bin/bash
# test_c04_ex01_ft_putstr.sh — hash verification
# Usage: bash test_c04_ex01_ft_putstr.sh [source_dir]
set -e

EXERCISE_ID="c04_ex01_ft_putstr"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C04: ft_putstr — review exercise)"
echo ""

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_putstr.c" ]; then
    echo "FAILED: File 'ft_putstr.c' not found"
    exit 1
fi
if [ ! -f "${SRC_DIR}/ft_putchar.c" ]; then
    echo "FAILED: File 'ft_putchar.c' not found"
    exit 1
fi

# Check for forbidden functions
for f in ft_putstr.c ft_putchar.c; do
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_putstr.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_putstr.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_putstr.c" "${SRC_DIR}/ft_putchar.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Basic strings ---
echo "Test 1: Basic strings..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_putchar(char c);
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("Hello, Piscine!");
	ft_putchar('\n');
	ft_putstr("");
	ft_putstr("42\n");
	ft_putstr("Review OK\n");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_putstr.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf 'Hello, Piscine!\n42\nReview OK')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic strings"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Empty string ---
echo "Test 2: Empty string..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_putchar(char c);
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("before");
	ft_putstr("");
	ft_putstr("after\n");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_putstr.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf 'beforeafter')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Empty string"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
