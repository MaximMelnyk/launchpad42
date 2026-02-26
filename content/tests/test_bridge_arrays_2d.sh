#!/bin/bash
# test_bridge_arrays_2d.sh — hash verification
# Usage: bash test_bridge_arrays_2d.sh [source_dir]
set -e

EXERCISE_ID="bridge_arrays_2d"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Bridge: 2D Arrays — grid[3][3], nested while, print matrix)"
echo ""

# Check source files exist
for f in main.c ft_putchar.c ft_putnbr.c; do
    if [ ! -f "${SRC_DIR}/${f}" ]; then
        echo "FAILED: File '${f}' not found"
        exit 1
    fi
done

# Check for forbidden functions
for f in main.c ft_putchar.c ft_putnbr.c; do
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

# Check for forbidden for loops
for f in main.c ft_putnbr.c; do
    if grep -qE '\bfor\s*\(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden 'for' loop in ${f} (use 'while')"
        exit 1
    fi
done

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/main.c" "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putnbr.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: 3x3 grid ---
echo "Test 1: 3x3 grid fill and print..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_putchar(char c);
void	ft_putnbr(int nb);

int	main(void)
{
	int	grid[3][3];
	int	row;
	int	col;

	row = 0;
	while (row < 3)
	{
		col = 0;
		while (col < 3)
		{
			grid[row][col] = row * 3 + col + 1;
			col++;
		}
		row++;
	}
	row = 0;
	while (row < 3)
	{
		col = 0;
		while (col < 3)
		{
			ft_putnbr(grid[row][col]);
			if (col < 2)
				ft_putchar(' ');
			col++;
		}
		ft_putchar('\n');
		row++;
	}
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putnbr.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '1 2 3\n4 5 6\n7 8 9')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: 3x3 grid test"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c

# --- Test 2: 2x2 grid ---
echo "Test 2: 2x2 grid..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
void	ft_putchar(char c);
void	ft_putnbr(int nb);

int	main(void)
{
	int	grid[2][2];
	int	row;
	int	col;

	grid[0][0] = 10;
	grid[0][1] = 20;
	grid[1][0] = 30;
	grid[1][1] = 40;
	row = 0;
	while (row < 2)
	{
		col = 0;
		while (col < 2)
		{
			ft_putnbr(grid[row][col]);
			if (col < 1)
				ft_putchar(' ');
			col++;
		}
		ft_putchar('\n');
		row++;
	}
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putnbr.c" /tmp/${EXERCISE_ID}_main2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '10 20\n30 40')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: 2x2 grid test"
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
echo "Code: $HASH"
exit 0
