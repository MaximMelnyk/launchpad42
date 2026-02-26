#!/bin/bash
# test_exam_l4_flood_fill.sh — hash verification
# Usage: bash test_exam_l4_flood_fill.sh [source_dir]
set -e

EXERCISE_ID="exam_l4_flood_fill"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 4: flood_fill on 2D char grid)"
echo ""

# Check source files exist
if [ ! -f "${SRC_DIR}/flood_fill.c" ]; then
    echo "FAILED: File 'flood_fill.c' not found"
    exit 1
fi
if [ ! -f "${SRC_DIR}/flood_fill.h" ]; then
    echo "FAILED: File 'flood_fill.h' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bmalloc\b' "${SRC_DIR}/flood_fill.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in flood_fill.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/flood_fill.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/flood_fill.c" "${SRC_DIR}/flood_fill.h" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

echo "Compiling..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include "flood_fill.h"

void	print_grid(char **tab, t_point size, int test_num)
{
	int		y;
	int		x;
	char	d;
	char	e;

	d = '0' + (test_num / 10);
	e = '0' + (test_num % 10);
	if (test_num >= 10)
		write(1, &d, 1);
	write(1, &e, 1);
	write(1, ":", 1);
	y = 0;
	while (y < size.y)
	{
		x = 0;
		while (x < size.x)
		{
			write(1, &tab[y][x], 1);
			x++;
		}
		if (y < size.y - 1)
			write(1, "|", 1);
		y++;
	}
	write(1, " ", 1);
}

int	main(void)
{
	/* Test 1: 5x5 grid, fill inner '0' region */
	{
		char r0[] = "11111";
		char r1[] = "10001";
		char r2[] = "10101";
		char r3[] = "10001";
		char r4[] = "11111";
		char *tab[] = {r0, r1, r2, r3, r4};
		t_point size = {5, 5};
		t_point begin = {3, 1};
		flood_fill(tab, size, begin);
		print_grid(tab, size, 1);
	}
	/* Test 2: 3x3 grid, all same char, fill entire grid */
	{
		char r0[] = "AAA";
		char r1[] = "AAA";
		char r2[] = "AAA";
		char *tab[] = {r0, r1, r2};
		t_point size = {3, 3};
		t_point begin = {1, 1};
		flood_fill(tab, size, begin);
		print_grid(tab, size, 2);
	}
	/* Test 3: 1x1 grid */
	{
		char r0[] = "X";
		char *tab[] = {r0};
		t_point size = {1, 1};
		t_point begin = {0, 0};
		flood_fill(tab, size, begin);
		print_grid(tab, size, 3);
	}
	/* Test 4: begin already 'F' - no change needed if char is 'F' */
	{
		char r0[] = "FFF";
		char r1[] = "F0F";
		char r2[] = "FFF";
		char *tab[] = {r0, r1, r2};
		t_point size = {3, 3};
		t_point begin = {0, 0};
		flood_fill(tab, size, begin);
		print_grid(tab, size, 4);
	}
	/* Test 5: diagonal NOT connected (4-directional only) */
	{
		char r0[] = "10";
		char r1[] = "01";
		char *tab[] = {r0, r1};
		t_point size = {2, 2};
		t_point begin = {0, 0};
		flood_fill(tab, size, begin);
		print_grid(tab, size, 5);
	}
	/* Test 6: L-shaped region */
	{
		char r0[] = "1100";
		char r1[] = "1000";
		char r2[] = "1010";
		char r3[] = "1110";
		char *tab[] = {r0, r1, r2, r3};
		t_point size = {4, 4};
		t_point begin = {1, 1};
		flood_fill(tab, size, begin);
		print_grid(tab, size, 6);
	}
	/* Test 7: single row */
	{
		char r0[] = "00100";
		char *tab[] = {r0};
		t_point size = {5, 1};
		t_point begin = {0, 0};
		flood_fill(tab, size, begin);
		print_grid(tab, size, 7);
	}
	/* Test 8: single column */
	{
		char r0[] = "0";
		char r1[] = "0";
		char r2[] = "1";
		char r3[] = "0";
		char *tab[] = {r0, r1, r2, r3};
		t_point size = {1, 4};
		t_point begin = {0, 0};
		flood_fill(tab, size, begin);
		print_grid(tab, size, 8);
	}
	/* Test 9: large-ish 6x4 with island */
	{
		char r0[] = "111111";
		char r1[] = "100011";
		char r2[] = "101011";
		char r3[] = "111111";
		char *tab[] = {r0, r1, r2, r3};
		t_point size = {6, 4};
		t_point begin = {2, 1};
		flood_fill(tab, size, begin);
		print_grid(tab, size, 9);
	}
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -I"${SRC_DIR}" -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/flood_fill.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:11111|1FFF1|1F1F1|1FFF1|11111 2:FFF|FFF|FFF 3:F 4:FFF|F0F|FFF 5:F0|01 6:1100|1FFF|1F1F|111F 7:FF100 8:F|F|1|0 9:111111|1FFF11|1F1F11|111111 "
TOTAL=9

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  All ${TOTAL} cases PASS"
    PASS=$TOTAL
else
    echo "  Output:   '$RESULT'"
    echo "  Expected: '$EXPECTED'"
    PASS=$(echo "$RESULT" | grep -o ":OK\|$(echo "$EXPECTED" | tr ' ' '\n' | head -1)" | wc -l 2>/dev/null || echo 0)
    # Count matching test blocks
    PASS=0
    i=1
    while [ $i -le $TOTAL ]; do
        exp_part=$(echo "$EXPECTED" | tr ' ' '\n' | sed -n "${i}p")
        if echo "$RESULT" | grep -qF "$exp_part"; then
            ((PASS++))
        fi
        ((i++))
    done
    FAIL=$((TOTAL - PASS))
    echo "  $PASS passed, $FAIL failed"
fi

rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c

if [ "$RESULT" != "$EXPECTED" ]; then
    echo ""
    echo "TESTS FAILED"
    exit 1
fi

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
