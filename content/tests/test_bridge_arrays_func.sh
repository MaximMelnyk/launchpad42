#!/bin/bash
# test_bridge_arrays_func.sh — hash verification
# Usage: bash test_bridge_arrays_func.sh [source_dir]
set -e

EXERCISE_ID="bridge_arrays_func"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Bridge: Arrays as Parameters — pass to function, modify in-place)"
echo ""

# Check source files exist
for f in main.c ft_putchar.c ft_putnbr.c ft_print_array.c ft_multiply_array.c; do
    if [ ! -f "${SRC_DIR}/${f}" ]; then
        echo "FAILED: File '${f}' not found"
        exit 1
    fi
done

# Check for forbidden functions
for f in ft_print_array.c ft_multiply_array.c ft_putchar.c ft_putnbr.c; do
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

# Check for forbidden for loops
for f in ft_print_array.c ft_multiply_array.c; do
    if grep -qE '\bfor\s*\(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden 'for' loop in ${f} (use 'while')"
        exit 1
    fi
done

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_print_array.c" "${SRC_DIR}/ft_multiply_array.c" \
        "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putnbr.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Print and multiply ---
echo "Test 1: Print, multiply, print again..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
void	ft_putchar(char c);
void	ft_putnbr(int nb);
void	ft_print_array(int *arr, int size);
void	ft_multiply_array(int *arr, int size);

int	main(void)
{
	int	arr[4];

	arr[0] = 1;
	arr[1] = 2;
	arr[2] = 3;
	arr[3] = 4;
	ft_print_array(arr, 4);
	ft_putchar('\n');
	ft_multiply_array(arr, 4);
	ft_print_array(arr, 4);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putnbr.c" \
    "${SRC_DIR}/ft_print_array.c" "${SRC_DIR}/ft_multiply_array.c" \
    /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf '1, 2, 3, 4\n2, 4, 6, 8')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Print and multiply test"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c

# --- Test 2: Double multiply ---
echo "Test 2: Double multiply..."
cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
void	ft_putchar(char c);
void	ft_putnbr(int nb);
void	ft_print_array(int *arr, int size);
void	ft_multiply_array(int *arr, int size);

int	main(void)
{
	int	arr[3];

	arr[0] = 5;
	arr[1] = 10;
	arr[2] = 15;
	ft_multiply_array(arr, 3);
	ft_multiply_array(arr, 3);
	ft_print_array(arr, 3);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putnbr.c" \
    "${SRC_DIR}/ft_print_array.c" "${SRC_DIR}/ft_multiply_array.c" \
    /tmp/${EXERCISE_ID}_main2.c

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="20, 40, 60"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Double multiply test"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c

# --- Test 3: Single element ---
echo "Test 3: Single element array..."
cat > /tmp/${EXERCISE_ID}_main3.c << 'TESTEOF'
void	ft_putchar(char c);
void	ft_putnbr(int nb);
void	ft_print_array(int *arr, int size);
void	ft_multiply_array(int *arr, int size);

int	main(void)
{
	int	arr[1];

	arr[0] = 7;
	ft_print_array(arr, 1);
	ft_putchar('\n');
	ft_multiply_array(arr, 1);
	ft_print_array(arr, 1);
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_putchar.c" "${SRC_DIR}/ft_putnbr.c" \
    "${SRC_DIR}/ft_print_array.c" "${SRC_DIR}/ft_multiply_array.c" \
    /tmp/${EXERCISE_ID}_main3.c

RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3=$(printf '7\n14')

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Single element test"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
