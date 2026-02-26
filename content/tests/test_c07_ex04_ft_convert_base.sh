#!/bin/bash
# test_c07_ex04_ft_convert_base.sh — hash verification
# Usage: bash test_c07_ex04_ft_convert_base.sh [source_dir]
set -e

EXERCISE_ID="c07_ex04_ft_convert_base"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C07 ex04: ft_convert_base — convert between number bases)"
echo ""

# Check source files exist
if [ ! -f "${SRC_DIR}/ft_convert_base.c" ]; then
    echo "FAILED: File 'ft_convert_base.c' not found"
    exit 1
fi
if [ ! -f "${SRC_DIR}/ft_convert_base_utils.c" ]; then
    echo "FAILED: File 'ft_convert_base_utils.c' not found"
    exit 1
fi

# Check for forbidden functions in both files
SRCS="${SRC_DIR}/ft_convert_base.c ${SRC_DIR}/ft_convert_base_utils.c"
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(|\batoi\s*\(|\bstrtol\s*\(' ${SRCS} 2>/dev/null; then
    echo "FAILED: Forbidden function found (printf/scanf/puts/atoi/strtol)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' ${SRCS} 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop found (use 'while')"
    exit 1
fi

# Check that malloc is used
if ! grep -qE '\bmalloc\s*\(' ${SRCS} 2>/dev/null; then
    echo "FAILED: Must use malloc"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette ${SRCS} || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Decimal to binary ---
echo "Test 1: Decimal 42 to binary..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_convert_base(char *nbr, char *base_from, char *base_to);

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

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

int	main(void)
{
	char	*result;

	result = ft_convert_base("42", "0123456789", "01");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    "${SRC_DIR}/ft_convert_base.c" "${SRC_DIR}/ft_convert_base_utils.c" \
    /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1="101010"

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Decimal 42 to binary"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test1

# --- Test 2: Binary to decimal ---
echo "Test 2: Binary 101010 to decimal..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_convert_base(char *nbr, char *base_from, char *base_to);

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

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

int	main(void)
{
	char	*result;

	result = ft_convert_base("101010", "01", "0123456789");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    "${SRC_DIR}/ft_convert_base.c" "${SRC_DIR}/ft_convert_base_utils.c" \
    /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="42"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Binary to decimal"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test2

# --- Test 3: Hex to decimal ---
echo "Test 3: Hex 2A to decimal..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_convert_base(char *nbr, char *base_from, char *base_to);

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

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

int	main(void)
{
	char	*result;

	result = ft_convert_base("2A", "0123456789ABCDEF", "0123456789");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
    "${SRC_DIR}/ft_convert_base.c" "${SRC_DIR}/ft_convert_base_utils.c" \
    /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3="42"

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: Hex 2A to decimal"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test3

# --- Test 4: Negative number ---
echo "Test 4: Negative decimal to hex..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_convert_base(char *nbr, char *base_from, char *base_to);

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

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

int	main(void)
{
	char	*result;

	result = ft_convert_base("-42", "0123456789", "0123456789ABCDEF");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 \
    "${SRC_DIR}/ft_convert_base.c" "${SRC_DIR}/ft_convert_base_utils.c" \
    /tmp/${EXERCISE_ID}_main.c
RESULT4=$(/tmp/${EXERCISE_ID}_test4)
EXPECTED4="-2A"

if [ "$RESULT4" != "$EXPECTED4" ]; then
    echo "FAILED: Negative decimal to hex"
    echo "Expected: '$EXPECTED4'"
    echo "Got:      '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test4

# --- Test 5: Zero ---
echo "Test 5: Zero conversion..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_convert_base(char *nbr, char *base_from, char *base_to);

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

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

int	main(void)
{
	char	*result;

	result = ft_convert_base("0", "0123456789", "01");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test5 \
    "${SRC_DIR}/ft_convert_base.c" "${SRC_DIR}/ft_convert_base_utils.c" \
    /tmp/${EXERCISE_ID}_main.c
RESULT5=$(/tmp/${EXERCISE_ID}_test5)
EXPECTED5="0"

if [ "$RESULT5" != "$EXPECTED5" ]; then
    echo "FAILED: Zero conversion"
    echo "Expected: '$EXPECTED5'"
    echo "Got:      '$RESULT5'"
    rm -f /tmp/${EXERCISE_ID}_test5 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test5

# --- Test 6: Invalid bases return NULL ---
echo "Test 6: Invalid bases return NULL..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_convert_base(char *nbr, char *base_from, char *base_to);

int	main(void)
{
	char	*result;
	int		pass;

	pass = 1;
	result = ft_convert_base("42", "0", "01");
	if (result != NULL)
		pass = 0;
	result = ft_convert_base("42", "01", "0");
	if (result != NULL)
		pass = 0;
	result = ft_convert_base("42", "0123456789", "0+1");
	if (result != NULL)
		pass = 0;
	result = ft_convert_base("42", "0-1", "0123456789");
	if (result != NULL)
		pass = 0;
	result = ft_convert_base("42", "011", "0123456789");
	if (result != NULL)
		pass = 0;
	result = ft_convert_base("42", "0123456789", "01 ");
	if (result != NULL)
		pass = 0;
	if (pass)
		write(1, "ALL_NULL_OK\n", 12);
	else
		write(1, "FAIL\n", 5);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test6 \
    "${SRC_DIR}/ft_convert_base.c" "${SRC_DIR}/ft_convert_base_utils.c" \
    /tmp/${EXERCISE_ID}_main.c
RESULT6=$(/tmp/${EXERCISE_ID}_test6)
EXPECTED6="ALL_NULL_OK"

if [ "$RESULT6" != "$EXPECTED6" ]; then
    echo "FAILED: Invalid bases should return NULL"
    echo "Expected: '$EXPECTED6'"
    echo "Got:      '$RESULT6'"
    rm -f /tmp/${EXERCISE_ID}_test6 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test6

# --- Test 7: Whitespace handling ---
echo "Test 7: Leading whitespace..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

char	*ft_convert_base(char *nbr, char *base_from, char *base_to);

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

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

int	main(void)
{
	char	*result;

	result = ft_convert_base("  \t42", "0123456789", "0123456789");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test7 \
    "${SRC_DIR}/ft_convert_base.c" "${SRC_DIR}/ft_convert_base_utils.c" \
    /tmp/${EXERCISE_ID}_main.c
RESULT7=$(/tmp/${EXERCISE_ID}_test7)
EXPECTED7="42"

if [ "$RESULT7" != "$EXPECTED7" ]; then
    echo "FAILED: Leading whitespace"
    echo "Expected: '$EXPECTED7'"
    echo "Got:      '$RESULT7'"
    rm -f /tmp/${EXERCISE_ID}_test7 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"
rm -f /tmp/${EXERCISE_ID}_test7 /tmp/${EXERCISE_ID}_main.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
