#!/bin/bash
# test_p0_d05_sign_checker.sh — hash verification
# Usage: bash test_p0_d05_sign_checker.sh [source_dir]
set -e

EXERCISE_ID="p0_d05_sign_checker"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
for f in ft_sign_checker.c ft_putchar.c ft_putstr.c; do
    if [ ! -f "${SRC_DIR}/${f}" ]; then
        echo "FAILED: File '${f}' not found"
        exit 1
    fi
done

# Check for forbidden functions
for f in ft_sign_checker.c ft_putchar.c ft_putstr.c; do
    if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

# Create test main
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_sign_checker(int n);

int	main(void)
{
	ft_sign_checker(42);
	ft_sign_checker(-7);
	ft_sign_checker(0);
	ft_sign_checker(2147483647);
	ft_sign_checker(-2147483648);
	return (0);
}
TESTEOF

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_sign_checker.c" "${SRC_DIR}/ft_putchar.c" \
    "${SRC_DIR}/ft_putstr.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

# Run and capture output
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(printf 'positive\nnegative\nzero\npositive\nnegative')

if [ "$RESULT" == "$EXPECTED" ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    echo "Code: $HASH"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 0
else
    echo "FAILED"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$RESULT'"
    rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
