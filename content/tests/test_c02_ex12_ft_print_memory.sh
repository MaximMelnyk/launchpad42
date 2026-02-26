#!/bin/bash
# test_c02_ex12_ft_print_memory.sh — hash verification
# Usage: bash test_c02_ex12_ft_print_memory.sh [source_dir]
set -e

EXERCISE_ID="c02_ex12_ft_print_memory"
SRC_DIR="${1:-.}"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_print_memory.c" ]; then
    echo "FAILED: File 'ft_print_memory.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_print_memory.c" 2>/dev/null; then
    echo "FAILED: Forbidden function detected (printf/scanf/puts)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_print_memory.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop detected (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_print_memory.c" || { echo "NORMINETTE FAILED"; exit 1; }
fi

# Test 1: Basic output format (check hex content + ASCII, ignore address)
cat > /tmp/${EXERCISE_ID}_test1.c << 'TESTEOF'
#include <unistd.h>

void	*ft_print_memory(void *addr, unsigned int size);

int	main(void)
{
	char	str[] = "Hello World!\n";

	ft_print_memory(str, 14);
	return (0);
}
TESTEOF

echo "Compiling test 1..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_print_memory.c" /tmp/${EXERCISE_ID}_test1.c

RESULT=$(/tmp/${EXERCISE_ID}_test1)

# Check hex content (skip address, check hex bytes and ASCII)
# "Hello World!\n\0" = 48 65 6c 6c 6f 20 57 6f  72 6c 64 21 0a 00
HEX_PART=$(echo "$RESULT" | head -1 | sed 's/^[0-9a-f]*: //')
EXPECTED_HEX="48 65 6c 6c 6f 20 57 6f  72 6c 64 21 0a 00"
EXPECTED_ASCII="Hello World!.."

# Extract hex portion (first 48 chars after address)
ACTUAL_HEX=$(echo "$HEX_PART" | cut -c1-39 | sed 's/ *$//')
ACTUAL_ASCII=$(echo "$HEX_PART" | rev | cut -c1-14 | rev | sed 's/^ *//')

# Flexible check: verify key hex bytes are present
if echo "$RESULT" | grep -q "48 65 6c 6c 6f 20 57 6f" && \
   echo "$RESULT" | grep -q "72 6c 64 21 0a 00"; then
    echo "Test 1 (hex content): OK"
    PASS=$((PASS + 1))
else
    echo "Test 1 (hex content): FAILED"
    echo "  Output: '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 2: Return value check
cat > /tmp/${EXERCISE_ID}_test2.c << 'TESTEOF'
#include <unistd.h>

void	*ft_print_memory(void *addr, unsigned int size);

int	main(void)
{
	char	str[] = "AB";
	void	*ret;

	ret = ft_print_memory(str, 2);
	if (ret == str)
		write(1, "RET_OK\n", 7);
	else
		write(1, "RET_FAIL\n", 9);
	return (0);
}
TESTEOF

echo "Compiling test 2..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_print_memory.c" /tmp/${EXERCISE_ID}_test2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)

if echo "$RESULT2" | grep -q "RET_OK"; then
    echo "Test 2 (return value): OK"
    PASS=$((PASS + 1))
else
    echo "Test 2 (return value): FAILED"
    echo "  Output: '$RESULT2'"
    FAIL=$((FAIL + 1))
fi

# Test 3: size = 0 (should print nothing)
cat > /tmp/${EXERCISE_ID}_test3.c << 'TESTEOF'
#include <unistd.h>

void	*ft_print_memory(void *addr, unsigned int size);

int	main(void)
{
	char	str[] = "Hello";

	ft_print_memory(str, 0);
	write(1, "EMPTY\n", 6);
	return (0);
}
TESTEOF

echo "Compiling test 3..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_print_memory.c" /tmp/${EXERCISE_ID}_test3.c

RESULT3=$(/tmp/${EXERCISE_ID}_test3)

if [ "$RESULT3" == "EMPTY" ]; then
    echo "Test 3 (size=0): OK"
    PASS=$((PASS + 1))
else
    echo "Test 3 (size=0): FAILED"
    echo "  Expected: 'EMPTY'"
    echo "  Got:      '$RESULT3'"
    FAIL=$((FAIL + 1))
fi

# Test 4: Multi-line output (>16 bytes)
cat > /tmp/${EXERCISE_ID}_test4.c << 'TESTEOF'
#include <unistd.h>

void	*ft_print_memory(void *addr, unsigned int size);

int	main(void)
{
	char	str[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345";

	ft_print_memory(str, 31);
	return (0);
}
TESTEOF

echo "Compiling test 4..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_print_memory.c" /tmp/${EXERCISE_ID}_test4.c

RESULT4=$(/tmp/${EXERCISE_ID}_test4)
LINE_COUNT=$(echo "$RESULT4" | wc -l)

# 31 bytes = 2 lines (16 + 15)
if [ "$LINE_COUNT" -eq 2 ]; then
    echo "Test 4 (multi-line 31 bytes = 2 lines): OK"
    PASS=$((PASS + 1))
else
    echo "Test 4 (multi-line): FAILED (expected 2 lines, got $LINE_COUNT)"
    echo "  Output: '$RESULT4'"
    FAIL=$((FAIL + 1))
fi

# Test 5: Address format (should be 16 hex chars)
ADDR_PART=$(echo "$RESULT4" | head -1 | cut -d':' -f1)
ADDR_LEN=${#ADDR_PART}

if [ "$ADDR_LEN" -eq 16 ]; then
    echo "Test 5 (address 16 hex chars): OK"
    PASS=$((PASS + 1))
else
    echo "Test 5 (address format): FAILED (expected 16 chars, got $ADDR_LEN: '$ADDR_PART')"
    FAIL=$((FAIL + 1))
fi

# Test 6: Check ASCII part contains printable dots for non-printable
cat > /tmp/${EXERCISE_ID}_test6.c << 'TESTEOF'
#include <unistd.h>

void	*ft_print_memory(void *addr, unsigned int size);

int	main(void)
{
	char	str[] = "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10";

	ft_print_memory(str, 16);
	return (0);
}
TESTEOF

echo "Compiling test 6..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test6 \
    "${SRC_DIR}/ft_print_memory.c" /tmp/${EXERCISE_ID}_test6.c

RESULT6=$(/tmp/${EXERCISE_ID}_test6)

if echo "$RESULT6" | grep -q '\.\.\.\.\.\.\.\.\.\.\.\.\.\.\.\.'; then
    echo "Test 6 (non-printable as dots): OK"
    PASS=$((PASS + 1))
else
    echo "Test 6 (non-printable as dots): FAILED"
    echo "  Output: '$RESULT6'"
    FAIL=$((FAIL + 1))
fi

# Cleanup
rm -f /tmp/${EXERCISE_ID}_test{1,2,3,4,6} /tmp/${EXERCISE_ID}_test{1,2,3,4,6}.c

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed (total: $((PASS + FAIL)))"

if [ $FAIL -eq 0 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo ""
    echo "ALL TESTS PASSED"
    echo "Code: $HASH"
    exit 0
else
    echo "SOME TESTS FAILED"
    exit 1
fi
