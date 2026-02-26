#!/bin/bash
# test_c04_ex02_ft_putnbr.sh — hash verification
# Usage: bash test_c04_ex02_ft_putnbr.sh [source_dir]
set -e

EXERCISE_ID="c04_ex02_ft_putnbr"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C04: ft_putnbr — review exercise)"
echo ""

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_putnbr.c" ]; then
    echo "FAILED: File 'ft_putnbr.c' not found"
    exit 1
fi
if [ ! -f "${SRC_DIR}/ft_putchar.c" ]; then
    echo "FAILED: File 'ft_putchar.c' not found"
    exit 1
fi

# Check for forbidden functions
for f in ft_putnbr.c ft_putchar.c; do
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(|\bitoa\b' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts/itoa)"
        exit 1
    fi
done

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_putnbr.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_putnbr.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_putnbr.c" "${SRC_DIR}/ft_putchar.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test: All cases ---
echo "Test: All cases (including INT_MIN)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_putchar(char c);
void	ft_putnbr(int nb);

int	main(void)
{
	ft_putnbr(42);
	ft_putchar('\n');
	ft_putnbr(-42);
	ft_putchar('\n');
	ft_putnbr(0);
	ft_putchar('\n');
	ft_putnbr(-2147483648);
	ft_putchar('\n');
	ft_putnbr(2147483647);
	ft_putchar('\n');
	ft_putnbr(1);
	ft_putchar('\n');
	ft_putnbr(-1);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_putnbr.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main.c
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf '42\n-42\n0\n-2147483648\n2147483647\n1\n-1')

if [ "$RESULT" != "$EXPECTED" ]; then
    echo "FAILED"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$RESULT'"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
