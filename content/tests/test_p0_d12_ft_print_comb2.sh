#!/bin/bash
# test_p0_d12_ft_print_comb2.sh — hash verification
# Usage: bash test_p0_d12_ft_print_comb2.sh [source_dir]
set -e

EXERCISE_ID="p0_d12_ft_print_comb2"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_print_comb2.c" ]; then
    echo "FAILED: File 'ft_print_comb2.c' not found"
    exit 1
fi
if [ ! -f "${SRC_DIR}/ft_putchar.c" ]; then
    echo "FAILED: File 'ft_putchar.c' not found"
    exit 1
fi

# Check for forbidden functions/loops
for f in ft_print_comb2.c ft_putchar.c; do
    if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_print_comb2.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_print_comb2.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_print_comb2.c" "${SRC_DIR}/ft_putchar.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Create test main
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_print_comb2(void);

int	main(void)
{
	ft_print_comb2();
	return (0);
}
TESTEOF

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_print_comb2.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

# Run and capture output
RESULT=$(/tmp/${EXERCISE_ID}_test)

# Generate expected output: all combinations of 2 two-digit numbers (00-99)
EXPECTED=$(python3 -c "
from itertools import combinations
pairs = []
for a, b in combinations(range(100), 2):
    pairs.append(f'{a:02d} {b:02d}')
print(', '.join(pairs), end='')
")

if [ "$RESULT" == "$EXPECTED" ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    show_compile_count
    echo "Code: $HASH"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 0
else
    echo "FAILED"
    echo "Expected (first 80 chars): '${EXPECTED:0:80}...'"
    echo "Got      (first 80 chars): '${RESULT:0:80}...'"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
