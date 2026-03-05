#!/bin/bash
# test_bridge_ft_putstr_len.sh — hash verification
# Usage: bash test_bridge_ft_putstr_len.sh [source_dir]
set -e

EXERCISE_ID="bridge_ft_putstr_len"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Bridge: ft_putstr + ft_strlen — print string with its length)"
echo ""

# Check source files exist
for f in main.c ft_putchar.c ft_putstr.c ft_strlen.c ft_putnbr.c; do
    if [ ! -f "${SRC_DIR}/${f}" ]; then
        echo "FAILED: File '${f}' not found"
        exit 1
    fi
done

# Check for forbidden functions
for f in ft_putstr.c ft_strlen.c ft_putchar.c ft_putnbr.c; do
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

# Check for forbidden for loops
for f in ft_putstr.c ft_strlen.c; do
    if grep -qE '\bfor\s*\(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden 'for' loop in ${f} (use 'while')"
        exit 1
    fi
done

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_putstr.c" "${SRC_DIR}/ft_strlen.c" \
        "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putnbr.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Combined putstr + strlen ---
echo "Test 1: String with length output..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_putchar(char c);
void	ft_putstr(char *str);
int		ft_strlen(char *str);
void	ft_putnbr(int nb);

int	main(void)
{
	ft_putstr("Hello");
	ft_putstr(": ");
	ft_putnbr(ft_strlen("Hello"));
	ft_putchar('\n');
	ft_putstr("");
	ft_putstr(": ");
	ft_putnbr(ft_strlen(""));
	ft_putchar('\n');
	ft_putstr("42");
	ft_putstr(": ");
	ft_putnbr(ft_strlen("42"));
	ft_putchar('\n');
	ft_putstr("Piscine is coming");
	ft_putstr(": ");
	ft_putnbr(ft_strlen("Piscine is coming"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putstr.c" \
    "${SRC_DIR}/ft_strlen.c" "${SRC_DIR}/ft_putnbr.c" \
    /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf 'Hello: 5\n: 0\n42: 2\nPiscine is coming: 17')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: String with length output"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c

# --- Test 2: Additional strings ---
echo "Test 2: Additional strings..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
void	ft_putchar(char c);
void	ft_putstr(char *str);
int		ft_strlen(char *str);
void	ft_putnbr(int nb);

int	main(void)
{
	ft_putstr("A");
	ft_putstr(": ");
	ft_putnbr(ft_strlen("A"));
	ft_putchar('\n');
	ft_putstr("0123456789");
	ft_putstr(": ");
	ft_putnbr(ft_strlen("0123456789"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putstr.c" \
    "${SRC_DIR}/ft_strlen.c" "${SRC_DIR}/ft_putnbr.c" \
    /tmp/${EXERCISE_ID}_main2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf 'A: 1\n0123456789: 10')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Additional strings test"
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
    show_compile_count
echo "Code: $HASH"
exit 0
