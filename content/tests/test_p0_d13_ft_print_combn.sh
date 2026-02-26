#!/bin/bash
# test_p0_d13_ft_print_combn.sh — hash verification
# Usage: bash test_p0_d13_ft_print_combn.sh [source_dir]
set -e

EXERCISE_ID="p0_d13_ft_print_combn"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_print_combn.c" ]; then
    echo "FAILED: File 'ft_print_combn.c' not found"
    exit 1
fi
if [ ! -f "${SRC_DIR}/ft_putchar.c" ]; then
    echo "FAILED: File 'ft_putchar.c' not found"
    exit 1
fi

# Check for forbidden functions/loops
for f in ft_print_combn.c ft_putchar.c; do
    if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_print_combn.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop in ft_print_combn.c (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_print_combn.c" "${SRC_DIR}/ft_putchar.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Create test main — tests n=1, n=2, n=3
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_print_combn(int n);

int	main(void)
{
	ft_print_combn(1);
	write(1, "\n", 1);
	ft_print_combn(2);
	write(1, "\n", 1);
	ft_print_combn(3);
	write(1, "\n", 1);
	return (0);
}
TESTEOF

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_print_combn.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

# Run and capture output
RESULT=$(/tmp/${EXERCISE_ID}_test)

# Generate expected output for n=1, n=2, n=3
EXPECTED=$(python3 -c "
from itertools import combinations

for n in [1, 2, 3]:
    combs = []
    for c in combinations(range(10), n):
        combs.append(''.join(map(str, c)))
    print(', '.join(combs))
")

if [ "$RESULT" == "$EXPECTED" ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    echo "Code: $HASH"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 0
else
    echo "FAILED"
    # Show per-line comparison
    echo "--- Expected lines ---"
    echo "$EXPECTED" | head -3
    echo "--- Got lines ---"
    echo "$RESULT" | head -3
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
