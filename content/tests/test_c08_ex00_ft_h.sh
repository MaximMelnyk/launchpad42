#!/bin/bash
# test_c08_ex00_ft_h.sh — hash verification
# Usage: bash test_c08_ex00_ft_h.sh [source_dir]
set -e

EXERCISE_ID="c08_ex00_ft_h"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C08 ex00: ft.h — header file with function prototypes)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft.h" ]; then
    echo "FAILED: File 'ft.h' not found"
    exit 1
fi

# Check for include guard (#ifndef FT_H)
if ! grep -q '#ifndef FT_H' "${SRC_DIR}/ft.h"; then
    echo "FAILED: Missing include guard (#ifndef FT_H)"
    exit 1
fi

# Check for #define FT_H (with or without space after #)
if ! grep -qE '#\s*define FT_H' "${SRC_DIR}/ft.h"; then
    echo "FAILED: Missing #define FT_H in include guard"
    exit 1
fi

# Check for #endif
if ! grep -q '#endif' "${SRC_DIR}/ft.h"; then
    echo "FAILED: Missing #endif in include guard"
    exit 1
fi

# Check for required prototypes
MISSING=""
if ! grep -qE 'void\s+ft_putchar\s*\(\s*char' "${SRC_DIR}/ft.h"; then
    MISSING="${MISSING} ft_putchar"
fi
if ! grep -qE 'void\s+ft_putstr\s*\(\s*char\s*\*' "${SRC_DIR}/ft.h"; then
    MISSING="${MISSING} ft_putstr"
fi
if ! grep -qE 'int\s+ft_strcmp\s*\(\s*char\s*\*' "${SRC_DIR}/ft.h"; then
    MISSING="${MISSING} ft_strcmp"
fi
if ! grep -qE 'int\s+ft_strlen\s*\(\s*char\s*\*' "${SRC_DIR}/ft.h"; then
    MISSING="${MISSING} ft_strlen"
fi
if ! grep -qE 'void\s+ft_swap\s*\(\s*int\s*\*' "${SRC_DIR}/ft.h"; then
    MISSING="${MISSING} ft_swap"
fi

if [ -n "$MISSING" ]; then
    echo "FAILED: Missing prototypes:${MISSING}"
    exit 1
fi
echo "Include guard: OK"
echo "All 5 prototypes found: OK"

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft.h" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft.h (printf/scanf/puts)"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft.h" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Compilation with ft.h ---
echo ""
echo "Test 1: Compilation with ft.h..."

# Create helper source files
cat > /tmp/${EXERCISE_ID}_ft_putchar.c << 'TESTEOF'
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}
TESTEOF

cat > /tmp/${EXERCISE_ID}_ft_putstr.c << 'TESTEOF'
#include <unistd.h>

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
TESTEOF

cat > /tmp/${EXERCISE_ID}_ft_strcmp.c << 'TESTEOF'
int	ft_strcmp(char *s1, char *s2)
{
	int	i;

	i = 0;
	while (s1[i] && s1[i] == s2[i])
		i++;
	return (s1[i] - s2[i]);
}
TESTEOF

cat > /tmp/${EXERCISE_ID}_ft_strlen.c << 'TESTEOF'
int	ft_strlen(char *str)
{
	int	i;

	i = 0;
	while (str[i])
		i++;
	return (i);
}
TESTEOF

cat > /tmp/${EXERCISE_ID}_ft_swap.c << 'TESTEOF'
void	ft_swap(int *a, int *b)
{
	int	tmp;

	tmp = *a;
	*a = *b;
	*b = tmp;
}
TESTEOF

cat > /tmp/${EXERCISE_ID}_main.c << TESTEOF
#include "${SRC_DIR}/ft.h"

int	main(void)
{
	int	a;
	int	b;

	ft_putchar('O');
	ft_putchar('K');
	ft_putchar('\n');
	ft_putstr("Header works!\n");
	a = 1;
	b = 2;
	ft_swap(&a, &b);
	if (a == 2 && b == 1)
		ft_putstr("Swap OK\n");
	if (ft_strlen("test") == 4)
		ft_putstr("Strlen OK\n");
	if (ft_strcmp("abc", "abc") == 0)
		ft_putstr("Strcmp OK\n");
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
    /tmp/${EXERCISE_ID}_main.c \
    /tmp/${EXERCISE_ID}_ft_putchar.c \
    /tmp/${EXERCISE_ID}_ft_putstr.c \
    /tmp/${EXERCISE_ID}_ft_strcmp.c \
    /tmp/${EXERCISE_ID}_ft_strlen.c \
    /tmp/${EXERCISE_ID}_ft_swap.c
if [ $? -ne 0 ]; then
    echo "FAILED: Compilation with ft.h failed"
    rm -f /tmp/${EXERCISE_ID}_*.c /tmp/${EXERCISE_ID}_test1
    exit 1
fi

RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1=$(printf 'OK\nHeader works!\nSwap OK\nStrlen OK\nStrcmp OK')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Output mismatch"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_*.c /tmp/${EXERCISE_ID}_test1
    exit 1
fi
echo "  PASS"

# --- Test 2: Double include (guard test) ---
echo "Test 2: Double include (guard test)..."

cat > /tmp/${EXERCISE_ID}_main2.c << TESTEOF
#include "${SRC_DIR}/ft.h"
#include "${SRC_DIR}/ft.h"

int	main(void)
{
	ft_putchar('G');
	ft_putchar('\n');
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
    /tmp/${EXERCISE_ID}_main2.c \
    /tmp/${EXERCISE_ID}_ft_putchar.c \
    /tmp/${EXERCISE_ID}_ft_putstr.c \
    /tmp/${EXERCISE_ID}_ft_strcmp.c \
    /tmp/${EXERCISE_ID}_ft_strlen.c \
    /tmp/${EXERCISE_ID}_ft_swap.c
if [ $? -ne 0 ]; then
    echo "FAILED: Double include causes compilation error (include guard broken)"
    rm -f /tmp/${EXERCISE_ID}_*.c /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2
    exit 1
fi

RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2="G"

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Double include output mismatch"
    rm -f /tmp/${EXERCISE_ID}_*.c /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2
    exit 1
fi
echo "  PASS"

# Cleanup
rm -f /tmp/${EXERCISE_ID}_*.c /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
