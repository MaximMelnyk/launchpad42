#!/bin/bash
# test_c08_ex01_ft_boolean_h.sh — hash verification
# Usage: bash test_c08_ex01_ft_boolean_h.sh [source_dir]
set -e

EXERCISE_ID="c08_ex01_ft_boolean_h"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C08 ex01: ft_boolean.h — TRUE/FALSE/EVEN macros + typedef)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_boolean.h" ]; then
    echo "FAILED: File 'ft_boolean.h' not found"
    exit 1
fi

# Check for include guard
if ! grep -q '#ifndef FT_BOOLEAN_H' "${SRC_DIR}/ft_boolean.h"; then
    echo "FAILED: Missing include guard (#ifndef FT_BOOLEAN_H)"
    exit 1
fi

if ! grep -qE '#\s*define FT_BOOLEAN_H' "${SRC_DIR}/ft_boolean.h"; then
    echo "FAILED: Missing #define FT_BOOLEAN_H"
    exit 1
fi

if ! grep -q '#endif' "${SRC_DIR}/ft_boolean.h"; then
    echo "FAILED: Missing #endif"
    exit 1
fi

# Check for required macros and typedef
if ! grep -qE '#\s*define TRUE' "${SRC_DIR}/ft_boolean.h"; then
    echo "FAILED: Missing #define TRUE"
    exit 1
fi

if ! grep -qE '#\s*define FALSE' "${SRC_DIR}/ft_boolean.h"; then
    echo "FAILED: Missing #define FALSE"
    exit 1
fi

if ! grep -qE '#\s*define EVEN\(' "${SRC_DIR}/ft_boolean.h"; then
    echo "FAILED: Missing #define EVEN(nbr) macro"
    exit 1
fi

if ! grep -qE '#\s*define EVEN_MSG' "${SRC_DIR}/ft_boolean.h"; then
    echo "FAILED: Missing #define EVEN_MSG"
    exit 1
fi

if ! grep -qE '#\s*define ODD_MSG' "${SRC_DIR}/ft_boolean.h"; then
    echo "FAILED: Missing #define ODD_MSG"
    exit 1
fi

if ! grep -q 'typedef' "${SRC_DIR}/ft_boolean.h"; then
    echo "FAILED: Missing typedef for t_bool"
    exit 1
fi

# Check for unistd.h include
if ! grep -qE '#\s*include\s*<unistd.h>' "${SRC_DIR}/ft_boolean.h"; then
    echo "FAILED: Missing #include <unistd.h>"
    exit 1
fi

echo "Include guard: OK"
echo "All macros found: OK"
echo "typedef found: OK"

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_boolean.h" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_boolean.h"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_boolean.h" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Even number of arguments (2 args) ---
echo ""
echo "Test 1: Even number of arguments (2 args)..."

cat > /tmp/${EXERCISE_ID}_main.c << TESTEOF
#include "${SRC_DIR}/ft_boolean.h"

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
}

int	main(int argc, char **argv)
{
	(void)argv;
	if (EVEN(argc - 1))
		ft_putstr(EVEN_MSG);
	else
		ft_putstr(ODD_MSG);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1 one two)
EXPECTED1="I have an even number of arguments."

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: 2 arguments should be EVEN"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 2: Odd number of arguments (1 arg) ---
echo "Test 2: Odd number of arguments (1 arg)..."
RESULT2=$(/tmp/${EXERCISE_ID}_test1 one)
EXPECTED2="I have an odd number of arguments."

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: 1 argument should be ODD"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 3: Zero arguments (even) ---
echo "Test 3: Zero arguments (even)..."
RESULT3=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED3="I have an even number of arguments."

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: 0 arguments should be EVEN"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 4: Three arguments (odd) ---
echo "Test 4: Three arguments (odd)..."
RESULT4=$(/tmp/${EXERCISE_ID}_test1 a b c)
EXPECTED4="I have an odd number of arguments."

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: 3 arguments should be ODD"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 5: TRUE/FALSE and t_bool usage ---
echo "Test 5: TRUE/FALSE and t_bool usage..."

cat > /tmp/${EXERCISE_ID}_main2.c << TESTEOF
#include "${SRC_DIR}/ft_boolean.h"

int	main(void)
{
	t_bool	flag;

	flag = TRUE;
	if (flag == TRUE)
		write(1, "T", 1);
	flag = FALSE;
	if (flag == FALSE)
		write(1, "F", 1);
	write(1, "\n", 1);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c
RESULT5=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED5="TF"

if [ "$RESULT5" != "$EXPECTED5" ]; then
    echo "FAILED: TRUE/FALSE/t_bool not working"
    echo "Expected: '$EXPECTED5'"
    echo "Got:      '$RESULT5'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c /tmp/${EXERCISE_ID}_main2.c
    exit 1
fi
echo "  PASS"

# --- Test 6: Double include (guard test) ---
echo "Test 6: Double include (guard test)..."

cat > /tmp/${EXERCISE_ID}_main3.c << TESTEOF
#include "${SRC_DIR}/ft_boolean.h"
#include "${SRC_DIR}/ft_boolean.h"

int	main(void)
{
	write(1, "G\n", 2);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c
if [ $? -ne 0 ]; then
    echo "FAILED: Double include causes compilation error (include guard broken)"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main*.c
    exit 1
fi
echo "  PASS"

# Cleanup
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main*.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
