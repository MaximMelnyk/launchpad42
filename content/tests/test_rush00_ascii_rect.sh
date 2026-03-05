#!/bin/bash
# test_rush00_ascii_rect.sh — hash verification
# Usage: bash test_rush00_ascii_rect.sh [source_dir]
set -e

EXERCISE_ID="rush00_ascii_rect"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Rush00: ASCII Rectangle)"
echo ""

# Check source files exist
MISSING=0
if [ ! -f "${SRC_DIR}/rush00.c" ]; then
    echo "FAILED: File 'rush00.c' not found"
    MISSING=1
fi
if [ ! -f "${SRC_DIR}/ft_putchar.c" ]; then
    echo "FAILED: File 'ft_putchar.c' not found"
    MISSING=1
fi
if [ "$MISSING" -eq 1 ]; then
    exit 1
fi

# Check for forbidden functions in rush00.c
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/rush00.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in rush00.c (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/rush00.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in rush00.c (use 'while')"
    exit 1
fi
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_putchar.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_putchar.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/rush00.c" "${SRC_DIR}/ft_putchar.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: rush(5, 3) ---
echo "Test 1: rush(5, 3)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	rush(int x, int y);

int	main(void)
{
	rush(5, 3);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/rush00.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main.c
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf 'o---o\n|   |\no---o')

if [ "$RESULT" != "$EXPECTED" ]; then
    echo "FAILED"
    echo "Expected:"
    echo "$EXPECTED"
    echo "Got:"
    echo "$RESULT"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 2: rush(5, 1) ---
echo "Test 2: rush(5, 1)..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
void	rush(int x, int y);

int	main(void)
{
	rush(5, 1);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/rush00.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main2.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf 'o---o')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c /tmp/${EXERCISE_ID}_main2.c
    exit 1
fi
echo "  PASS"

# --- Test 3: rush(1, 5) ---
echo "Test 3: rush(1, 5)..."
cat > /tmp/${EXERCISE_ID}_main3.c << 'TESTEOF'
void	rush(int x, int y);

int	main(void)
{
	rush(1, 5);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/rush00.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main3.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf 'o\n|\n|\n|\no')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c /tmp/${EXERCISE_ID}_main2.c /tmp/${EXERCISE_ID}_main3.c
    exit 1
fi
echo "  PASS"

# --- Test 4: rush(1, 1) ---
echo "Test 4: rush(1, 1)..."
cat > /tmp/${EXERCISE_ID}_main4.c << 'TESTEOF'
void	rush(int x, int y);

int	main(void)
{
	rush(1, 1);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/rush00.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main4.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4=$(printf 'o')

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c /tmp/${EXERCISE_ID}_main2.c /tmp/${EXERCISE_ID}_main3.c /tmp/${EXERCISE_ID}_main4.c
    exit 1
fi
echo "  PASS"

# --- Test 5: rush(0, 5) — no output ---
echo "Test 5: rush(0, 5) — no output..."
cat > /tmp/${EXERCISE_ID}_main5.c << 'TESTEOF'
void	rush(int x, int y);

int	main(void)
{
	rush(0, 5);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test5 \
    "${SRC_DIR}/rush00.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main5.c
RESULT5=$(/tmp/${EXERCISE_ID}_test5)
EXPECTED5=""

if [ "$RESULT5" != "$EXPECTED5" ]; then
    echo "FAILED"
    echo "Expected: (empty)"
    echo "Got:      '$RESULT5'"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_test5 /tmp/${EXERCISE_ID}_main.c /tmp/${EXERCISE_ID}_main2.c /tmp/${EXERCISE_ID}_main3.c /tmp/${EXERCISE_ID}_main4.c /tmp/${EXERCISE_ID}_main5.c
    exit 1
fi
echo "  PASS"

# --- Test 6: rush(3, 3) ---
echo "Test 6: rush(3, 3)..."
cat > /tmp/${EXERCISE_ID}_main6.c << 'TESTEOF'
void	rush(int x, int y);

int	main(void)
{
	rush(3, 3);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test6 \
    "${SRC_DIR}/rush00.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main6.c
RESULT6=$(/tmp/${EXERCISE_ID}_test6)
EXPECTED6=$(printf 'o-o\n| |\no-o')

if [ "$RESULT6" != "$EXPECTED6" ]; then
    echo "FAILED"
    echo "Expected:"
    echo "$EXPECTED6"
    echo "Got:"
    echo "$RESULT6"
    rm -f /tmp/${EXERCISE_ID}_test* /tmp/${EXERCISE_ID}_main*.c
    exit 1
fi
echo "  PASS"

# Cleanup
rm -f /tmp/${EXERCISE_ID}_test* /tmp/${EXERCISE_ID}_main*.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
