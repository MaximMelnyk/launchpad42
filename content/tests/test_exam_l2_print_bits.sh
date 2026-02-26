#!/bin/bash
# test_exam_l2_print_bits.sh — hash verification
# Usage: bash test_exam_l2_print_bits.sh [source_dir]
set -e

EXERCISE_ID="exam_l2_print_bits"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 2: Print 8 bits of unsigned char)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/print_bits.c" ]; then
    echo "FAILED: File 'print_bits.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/print_bits.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in print_bits.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/print_bits.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/print_bits.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

echo "Compiling..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

void	print_bits(unsigned char octet);

int	main(void)
{
	print_bits(0);
	write(1, "|", 1);
	print_bits(1);
	write(1, "|", 1);
	print_bits(2);
	write(1, "|", 1);
	print_bits(65);
	write(1, "|", 1);
	print_bits(127);
	write(1, "|", 1);
	print_bits(128);
	write(1, "|", 1);
	print_bits(255);
	write(1, "|", 1);
	print_bits(42);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/print_bits.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="00000000|00000001|00000010|01000001|01111111|10000000|11111111|00101010"
TOTAL=8

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  All ${TOTAL} cases PASS"
    PASS=$TOTAL
else
    echo "  Output: '$RESULT'"
    echo "  Expect: '$EXPECTED'"
    # Count matching segments
    IFS='|' read -ra RES_PARTS <<< "$RESULT"
    IFS='|' read -ra EXP_PARTS <<< "$EXPECTED"
    PASS=0
    FAIL=0
    i=0
    while [ $i -lt ${#EXP_PARTS[@]} ]; do
        if [ "${RES_PARTS[$i]}" == "${EXP_PARTS[$i]}" ]; then
            ((PASS++))
        else
            ((FAIL++))
        fi
        ((i++))
    done
    echo "  $PASS passed, $FAIL failed"
fi

rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c

if [ $FAIL -ne 0 ]; then
    echo ""
    echo "TESTS FAILED: $FAIL failed, $PASS passed"
    exit 1
fi

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
