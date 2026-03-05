#!/bin/bash
# test_c_maint_02_putnbr.sh — hash verification
# Usage: bash test_c_maint_02_putnbr.sh [source_dir]
# Stricter than Phase 0: additional edge cases (10, -10, 100, single digits)
set -e

EXERCISE_ID="c_maint_02_putnbr"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C Maintenance: ft_putnbr from memory)"
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
    if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_putnbr.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_putnbr.c (use 'while')"
    exit 1
fi

# Check for forbidden itoa
if grep -q 'itoa' "${SRC_DIR}/ft_putnbr.c" 2>/dev/null; then
    echo "FAILED: Forbidden function 'itoa' in ft_putnbr.c"
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

# Create test main with extended edge cases
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_putnbr(int nb);
void	ft_putchar(char c);

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
	ft_putnbr(10);
	ft_putchar('\n');
	ft_putnbr(-10);
	ft_putchar('\n');
	ft_putnbr(100);
	ft_putchar('\n');
	return (0);
}
TESTEOF

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_putnbr.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

# Run and capture output
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf '42\n-42\n0\n-2147483648\n2147483647\n1\n-1\n10\n-10\n100')

if [ "$RESULT" == "$EXPECTED" ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    show_compile_count
    echo "Code: $HASH"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 0
else
    echo "FAILED"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$RESULT'"
    # Show line-by-line diff for debugging
    echo ""
    echo "Line-by-line comparison:"
    paste <(echo "$EXPECTED" | nl) <(echo "$RESULT" | nl) | while IFS=$'\t' read -r n1 exp n2 got; do
        if [ "$exp" != "$got" ]; then
            echo "  Line ${n1}: expected '${exp}' got '${got}' <-- MISMATCH"
        fi
    done
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
