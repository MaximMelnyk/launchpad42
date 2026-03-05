#!/bin/bash
# test_c08_ex03_ft_point_h.sh — hash verification
# Usage: bash test_c08_ex03_ft_point_h.sh [source_dir]
set -e

EXERCISE_ID="c08_ex03_ft_point_h"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C08 ex03: ft_point.h — struct s_point / t_point)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_point.h" ]; then
    echo "FAILED: File 'ft_point.h' not found"
    exit 1
fi

# Check for include guard
if ! grep -q '#ifndef FT_POINT_H' "${SRC_DIR}/ft_point.h"; then
    echo "FAILED: Missing include guard (#ifndef FT_POINT_H)"
    exit 1
fi

if ! grep -qE '#\s*define FT_POINT_H' "${SRC_DIR}/ft_point.h"; then
    echo "FAILED: Missing #define FT_POINT_H"
    exit 1
fi

if ! grep -q '#endif' "${SRC_DIR}/ft_point.h"; then
    echo "FAILED: Missing #endif"
    exit 1
fi

# Check for struct and typedef
if ! grep -q 'struct s_point' "${SRC_DIR}/ft_point.h"; then
    echo "FAILED: Missing 'struct s_point'"
    exit 1
fi

if ! grep -q 't_point' "${SRC_DIR}/ft_point.h"; then
    echo "FAILED: Missing typedef 't_point'"
    exit 1
fi

if ! grep -q 'typedef' "${SRC_DIR}/ft_point.h"; then
    echo "FAILED: Missing 'typedef' keyword"
    exit 1
fi

echo "Include guard: OK"
echo "struct s_point found: OK"
echo "typedef t_point found: OK"

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/ft_point.h" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_point.h"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_point.h" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# --- Test 1: Create and access point ---
echo ""
echo "Test 1: Create and access t_point..."

cat > /tmp/${EXERCISE_ID}_main.c << TESTEOF
#include <unistd.h>
#include "${SRC_DIR}/ft_point.h"

void	ft_putnbr(int nb)
{
	char	c;

	if (nb < 0)
	{
		write(1, "-", 1);
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	c = (nb % 10) + '0';
	write(1, &c, 1);
}

int	main(void)
{
	t_point	a;

	a.x = 1;
	a.y = 2;
	ft_putnbr(a.x);
	write(1, " ", 1);
	ft_putnbr(a.y);
	write(1, "\n", 1);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
RESULT1=$(/tmp/${EXERCISE_ID}_test1)
EXPECTED1="1 2"

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Basic point creation"
    echo "Expected: '$EXPECTED1'"
    echo "Got:      '$RESULT1'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 2: Pointer to struct (arrow operator) ---
echo "Test 2: Pointer to struct..."

cat > /tmp/${EXERCISE_ID}_main.c << TESTEOF
#include <unistd.h>
#include "${SRC_DIR}/ft_point.h"

void	ft_putnbr(int nb)
{
	char	c;

	if (nb < 0)
	{
		write(1, "-", 1);
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	c = (nb % 10) + '0';
	write(1, &c, 1);
}

void	set_point(t_point *p, int x, int y)
{
	p->x = x;
	p->y = y;
}

int	main(void)
{
	t_point	a;
	t_point	b;

	set_point(&a, -3, 7);
	set_point(&b, 0, 0);
	ft_putnbr(a.x);
	write(1, " ", 1);
	ft_putnbr(a.y);
	write(1, "\n", 1);
	ft_putnbr(b.x);
	write(1, " ", 1);
	ft_putnbr(b.y);
	write(1, "\n", 1);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
RESULT2=$(/tmp/${EXERCISE_ID}_test2)
EXPECTED2=$(printf '-3 7\n0 0')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Pointer access"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 3: struct s_point also works ---
echo "Test 3: struct s_point (without typedef)..."

cat > /tmp/${EXERCISE_ID}_main.c << TESTEOF
#include <unistd.h>
#include "${SRC_DIR}/ft_point.h"

void	ft_putnbr(int nb)
{
	char	c;

	if (nb < 0)
	{
		write(1, "-", 1);
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	c = (nb % 10) + '0';
	write(1, &c, 1);
}

int	main(void)
{
	struct s_point	p;

	p.x = 42;
	p.y = -1;
	ft_putnbr(p.x);
	write(1, " ", 1);
	ft_putnbr(p.y);
	write(1, "\n", 1);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
RESULT3=$(/tmp/${EXERCISE_ID}_test3)
EXPECTED3="42 -1"

if [ "$RESULT3" != "$EXPECTED3" ]; then
    echo "FAILED: struct s_point access"
    echo "Expected: '$EXPECTED3'"
    echo "Got:      '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# --- Test 4: Double include (guard test) ---
echo "Test 4: Double include (guard test)..."

cat > /tmp/${EXERCISE_ID}_main.c << TESTEOF
#include <unistd.h>
#include "${SRC_DIR}/ft_point.h"
#include "${SRC_DIR}/ft_point.h"

int	main(void)
{
	t_point	p;

	p.x = 1;
	(void)p;
	write(1, "G\n", 2);
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "FAILED: Double include causes compilation error"
    rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c
    exit 1
fi
echo "  PASS"

# Cleanup
rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_test4 /tmp/${EXERCISE_ID}_main.c

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
