#!/bin/bash
# test_c_maint_01_putstr.sh — hash verification
# Usage: bash test_c_maint_01_putstr.sh [source_dir]
# Stricter than Phase 0: also tests empty string and NULL handling
set -e

EXERCISE_ID="c_maint_01_putstr"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C Maintenance: ft_putstr from memory)"
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
    if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/${f}" 2>/dev/null; then
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
cat > /tmp/${EXERCISE_ID}_main1.c << 'TESTEOF'
void	ft_putstr(char *str);
void	ft_putchar(char c);

int	main(void)
{
	ft_putstr("Hello, Piscine!");
	ft_putchar('\n');
	ft_putstr("42 Paris");
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_putstr.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main1.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main1.c
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf 'Hello, Piscine!\n42 Paris')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic string test"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main1.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main1.c

# --- Test 2: Empty string ---
echo "Test 2: Empty string..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
void	ft_putstr(char *str);
void	ft_putchar(char c);

int	main(void)
{
	ft_putstr("before");
	ft_putstr("");
	ft_putstr("after\n");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_putstr.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf 'beforeafter')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Empty string test"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c

# --- Test 3: NULL handling ---
echo "Test 3: NULL handling (should not crash)..."
cat > /tmp/${EXERCISE_ID}_main3.c << 'TESTEOF'
#include <stdlib.h>

void	ft_putstr(char *str);
void	ft_putchar(char c);

int	main(void)
{
	ft_putstr((void *)0);
	ft_putstr("survived\n");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_putstr.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main3.c

# Run with timeout to catch segfaults
RESULT3=$(timeout 5 /tmp/${EXERCISE_ID}_test3 2>/dev/null) || {
    echo "FAILED: Crashed on NULL input (segfault or timeout)"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c
    exit 1
}

if echo "$RESULT3" | grep -q "survived"; then
    echo "  PASS"
else
    echo "FAILED: NULL test - program did not continue after NULL"
    echo "Got: '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c
    exit 1
fi
rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c

# --- Test 4: Full integration ---
echo "Test 4: Full integration..."
cat > /tmp/${EXERCISE_ID}_main4.c << 'TESTEOF'
void	ft_putstr(char *str);
void	ft_putchar(char c);

int	main(void)
{
	ft_putstr("Hello, Piscine!");
	ft_putchar('\n');
	ft_putstr("");
	ft_putstr("42 Paris");
	ft_putchar('\n');
	ft_putstr("Memory test OK");
	ft_putchar('\n');
	ft_putstr((void *)0);
	ft_putstr("After NULL\n");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_putstr.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main4.c

RESULT4=$(timeout 5 /tmp/${EXERCISE_ID}_test4 2>/dev/null) || {
    echo "FAILED: Crashed on full integration test"
    rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main4.c
    exit 1
}
EXPECTED4=$(printf 'Hello, Piscine!\n42 Paris\nMemory test OK\nAfter NULL')

if [ "$RESULT4" == "$EXPECTED4" ]; then
    echo "  PASS"
else
    echo "FAILED: Full integration test"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main4.c
    exit 1
fi
rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main4.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
