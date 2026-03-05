#!/bin/bash
# test_c05_ex08_ft_ten_queens_puzzle.sh — hash verification
# Usage: bash test_c05_ex08_ft_ten_queens_puzzle.sh [source_dir]
set -e

EXERCISE_ID="c05_ex08_ft_ten_queens_puzzle"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C05: ft_ten_queens_puzzle)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_ten_queens_puzzle.c" ]; then
    echo "FAILED: File 'ft_ten_queens_puzzle.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(|\bmalloc\s*\(' "${SRC_DIR}/ft_ten_queens_puzzle.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_ten_queens_puzzle.c (printf/scanf/puts/malloc)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_ten_queens_puzzle.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_ten_queens_puzzle.c (use 'while')"
    exit 1
fi

# Check that write is used
if ! grep -qE '\bwrite\s*\(' "${SRC_DIR}/ft_ten_queens_puzzle.c" 2>/dev/null; then
    echo "FAILED: Must use write() for output"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_ten_queens_puzzle.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Compile and run, check return value = 724 ---
echo "Test 1: Compile and check return value (should be 724)..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

int	ft_ten_queens_puzzle(void);

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
	if (nb < 0)
	{
		ft_putchar('-');
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}

int	main(void)
{
	int	count;

	count = ft_ten_queens_puzzle();
	ft_putnbr(count);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_ten_queens_puzzle.c" /tmp/${EXERCISE_ID}_main.c

echo "  Running (this may take a few seconds)..."
FULL_OUTPUT=$(/tmp/${EXERCISE_ID}_test1)

# The last line should be "724" (the return value)
LAST_LINE=$(echo "$FULL_OUTPUT" | tail -1)
if [ "$LAST_LINE" != "724" ]; then
    echo "FAILED: Return value should be 724"
    echo "Got last line: '$LAST_LINE'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS (return value = 724)"

# --- Test 2: Check number of solution lines = 724 ---
echo "Test 2: Check number of solution lines..."
# All lines except the last one (which is the count) should be solutions
SOLUTION_LINES=$(echo "$FULL_OUTPUT" | head -n -1 | wc -l)
if [ "$SOLUTION_LINES" != "724" ]; then
    echo "FAILED: Expected 724 solution lines, got $SOLUTION_LINES"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS (724 solution lines)"

# --- Test 3: Check solution format (each line = 10 digits) ---
echo "Test 3: Check solution format (10 digits per line)..."
BAD_FORMAT=$(echo "$FULL_OUTPUT" | head -n -1 | grep -cvE '^[0-9]{10}$' || true)
if [ "$BAD_FORMAT" != "0" ]; then
    echo "FAILED: $BAD_FORMAT lines have incorrect format (expected 10 digits per line)"
    echo "First bad line:"
    echo "$FULL_OUTPUT" | head -n -1 | grep -vE '^[0-9]{10}$' | head -1
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS (all lines are 10 digits)"

# --- Test 4: Verify known first solutions ---
echo "Test 4: Verify known first solutions..."
FIRST_LINE=$(echo "$FULL_OUTPUT" | head -1)
if [ "$FIRST_LINE" != "0257948136" ]; then
    echo "FAILED: First solution should be 0257948136, got '$FIRST_LINE'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS (first solution correct)"

# --- Test 5: Validate solutions (no queens attack each other) ---
echo "Test 5: Validate all solutions (no attacks)..."
cat > /tmp/${EXERCISE_ID}_validate.c << 'VALIDATEEOF'
#include <unistd.h>
#include <stdlib.h>

/* Reads solutions from stdin and validates them */

int	ft_strlen(char *str)
{
	int	i;

	i = 0;
	while (str[i])
		i++;
	return (i);
}

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
	if (nb < 0)
	{
		ft_putchar('-');
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}

int	validate_solution(char *line)
{
	int	i;
	int	j;
	int	cols[10];

	if (ft_strlen(line) != 10)
		return (0);
	i = 0;
	while (i < 10)
	{
		if (line[i] < '0' || line[i] > '9')
			return (0);
		cols[i] = line[i] - '0';
		i++;
	}
	i = 0;
	while (i < 10)
	{
		j = i + 1;
		while (j < 10)
		{
			if (cols[i] == cols[j])
				return (0);
			if (cols[i] - cols[j] == i - j)
				return (0);
			if (cols[i] - cols[j] == j - i)
				return (0);
			j++;
		}
		i++;
	}
	return (1);
}

int	main(void)
{
	char	buf[12];
	int		idx;
	int		n;
	int		valid;
	int		line_num;
	char	c;

	valid = 1;
	line_num = 0;
	idx = 0;
	while (read(0, &c, 1) == 1)
	{
		if (c == '\n')
		{
			buf[idx] = '\0';
			line_num++;
			if (idx == 10 && !validate_solution(buf))
			{
				write(1, "INVALID:", 8);
				write(1, buf, idx);
				ft_putchar('\n');
				valid = 0;
			}
			idx = 0;
		}
		else if (idx < 11)
		{
			buf[idx] = c;
			idx++;
		}
	}
	if (valid)
		write(1, "ALL_VALID\n", 10);
	return (valid ? 0 : 1);
}
VALIDATEEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_validate /tmp/${EXERCISE_ID}_validate.c

# Feed solutions to validator (exclude last line which is the count)
VALIDATE_RESULT=$(echo "$FULL_OUTPUT" | head -n -1 | /tmp/${EXERCISE_ID}_validate)
if [ "$VALIDATE_RESULT" != "ALL_VALID" ]; then
    echo "FAILED: Some solutions are invalid"
    echo "$VALIDATE_RESULT"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c /tmp/${EXERCISE_ID}_validate /tmp/${EXERCISE_ID}_validate.c
    exit 1
fi
echo "  PASS (all 724 solutions valid)"

# --- Test 6: Check uniqueness ---
echo "Test 6: Check all solutions are unique..."
UNIQUE_COUNT=$(echo "$FULL_OUTPUT" | head -n -1 | sort -u | wc -l)
if [ "$UNIQUE_COUNT" != "724" ]; then
    echo "FAILED: Expected 724 unique solutions, got $UNIQUE_COUNT"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c /tmp/${EXERCISE_ID}_validate /tmp/${EXERCISE_ID}_validate.c
    exit 1
fi
echo "  PASS (all 724 solutions unique)"

# Cleanup
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c /tmp/${EXERCISE_ID}_validate /tmp/${EXERCISE_ID}_validate.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
