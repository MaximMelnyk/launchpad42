#!/bin/bash
# test_c02_ex11_ft_putstr_non_printable.sh — hash verification
# Usage: bash test_c02_ex11_ft_putstr_non_printable.sh [source_dir]
set -e

EXERCISE_ID="c02_ex11_ft_putstr_non_printable"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_putstr_non_printable.c" ]; then
    echo "FAILED: File 'ft_putstr_non_printable.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_putstr_non_printable.c" 2>/dev/null; then
    echo "FAILED: Forbidden function detected (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_putstr_non_printable.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop detected (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_putstr_non_printable.c" || { echo "NORMINETTE FAILED"; exit 1; }
fi

# Test 1: String with newline
cat > /tmp/${EXERCISE_ID}_test1.c << 'TESTEOF'
#include <unistd.h>

void	ft_putstr_non_printable(char *str);

int	main(void)
{
	ft_putstr_non_printable("Coucou\ntu vas bien ?");
	write(1, "\n", 1);
	return (0);
}
TESTEOF

echo "Compiling test 1..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_putstr_non_printable.c" /tmp/${EXERCISE_ID}_test1.c

RESULT=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED='Coucou\x0atu vas bien ?'

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "Test 1 (newline replacement): OK"
    PASS=$((PASS + 1))
else
    echo "Test 1 (newline replacement): FAILED"
    echo "  Expected: '$EXPECTED'"
    echo "  Got:      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 2: Tabs
cat > /tmp/${EXERCISE_ID}_test2.c << 'TESTEOF'
#include <unistd.h>

void	ft_putstr_non_printable(char *str);

int	main(void)
{
	ft_putstr_non_printable("Hello\t\tWorld");
	write(1, "\n", 1);
	return (0);
}
TESTEOF

echo "Compiling test 2..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_putstr_non_printable.c" /tmp/${EXERCISE_ID}_test2.c

RESULT=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED='Hello\x09\x09World'

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "Test 2 (double tab): OK"
    PASS=$((PASS + 1))
else
    echo "Test 2 (double tab): FAILED"
    echo "  Expected: '$EXPECTED'"
    echo "  Got:      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 3: Empty string
cat > /tmp/${EXERCISE_ID}_test3.c << 'TESTEOF'
#include <unistd.h>

void	ft_putstr_non_printable(char *str);

int	main(void)
{
	ft_putstr_non_printable("");
	write(1, "DONE\n", 5);
	return (0);
}
TESTEOF

echo "Compiling test 3..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_putstr_non_printable.c" /tmp/${EXERCISE_ID}_test3.c

RESULT=$(/tmp/${EXERCISE_ID}_test3)

if [ "$RESULT" == "DONE" ]; then
    echo "Test 3 (empty string): OK"
    PASS=$((PASS + 1))
else
    echo "Test 3 (empty string): FAILED"
    FAIL=$((FAIL + 1))
fi

# Test 4: All printable
cat > /tmp/${EXERCISE_ID}_test4.c << 'TESTEOF'
#include <unistd.h>

void	ft_putstr_non_printable(char *str);

int	main(void)
{
	ft_putstr_non_printable("ABC 123 ~!");
	write(1, "\n", 1);
	return (0);
}
TESTEOF

echo "Compiling test 4..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_putstr_non_printable.c" /tmp/${EXERCISE_ID}_test4.c

RESULT=$(/tmp/${EXERCISE_ID}_test4)

if [ "$RESULT" == "ABC 123 ~!" ]; then
    echo "Test 4 (all printable): OK"
    PASS=$((PASS + 1))
else
    echo "Test 4 (all printable): FAILED"
    echo "  Expected: 'ABC 123 ~!'"
    echo "  Got:      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Cleanup
rm -f /tmp/${EXERCISE_ID}_test{1,2,3,4} /tmp/${EXERCISE_ID}_test{1,2,3,4}.c

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed (total: $((PASS + FAIL)))"

if [ $FAIL -eq 0 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo ""
    echo "ALL TESTS PASSED"
    show_compile_count
    echo "Code: $HASH"
    exit 0
else
    echo "SOME TESTS FAILED"
    exit 1
fi
