#!/bin/bash
# test_c09_ex01_makefile.sh — hash verification
# Usage: bash test_c09_ex01_makefile.sh [source_dir]
# Source dir should contain: Makefile + all .c files + ft.h

EXERCISE_ID="c09_ex01_makefile"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C09 ex01: Makefile for libft — all/clean/fclean/re + no relink)"
echo ""

# Check Makefile exists
if [ ! -f "${SRC_DIR}/Makefile" ]; then
    echo "FAILED: Makefile not found"
    exit 1
fi

# Check required source files
SRCS="ft_putchar.c ft_putstr.c ft_putnbr.c ft_strlen.c ft_strcmp.c ft_swap.c"
for SRC in $SRCS; do
    if [ ! -f "${SRC_DIR}/${SRC}" ]; then
        echo "FAILED: Source file '${SRC}' not found"
        exit 1
    fi
done

if [ ! -f "${SRC_DIR}/ft.h" ]; then
    echo "FAILED: Header 'ft.h' not found"
    exit 1
fi

# Check Makefile contains required variables/rules
echo "Checking Makefile structure..."
if ! grep -q 'NAME' "${SRC_DIR}/Makefile" 2>/dev/null; then
    echo "FAILED: Makefile missing NAME variable"
    exit 1
fi
if ! grep -q 'CFLAGS' "${SRC_DIR}/Makefile" 2>/dev/null; then
    echo "FAILED: Makefile missing CFLAGS variable"
    exit 1
fi
if ! grep -q '\-Wall' "${SRC_DIR}/Makefile" 2>/dev/null; then
    echo "FAILED: Makefile CFLAGS missing -Wall"
    exit 1
fi
if ! grep -q '\-Wextra' "${SRC_DIR}/Makefile" 2>/dev/null; then
    echo "FAILED: Makefile CFLAGS missing -Wextra"
    exit 1
fi
if ! grep -q '\-Werror' "${SRC_DIR}/Makefile" 2>/dev/null; then
    echo "FAILED: Makefile CFLAGS missing -Werror"
    exit 1
fi
echo "  Structure OK"

# --- Work in a temp copy to avoid modifying student dir ---
TMPDIR=$(mktemp -d)
trap "rm -rf ${TMPDIR}" EXIT
cp "${SRC_DIR}"/Makefile "${SRC_DIR}"/*.c "${SRC_DIR}"/ft.h "${TMPDIR}/" 2>/dev/null

cd "${TMPDIR}"

# --- Test 1: make all ---
echo "Test 1: make all..."
MAKE_OUTPUT=$(make 2>&1)
if [ $? -ne 0 ]; then
    echo "FAILED: 'make' returned error"
    echo "$MAKE_OUTPUT"
    exit 1
fi

if [ ! -f "libft.a" ]; then
    echo "FAILED: libft.a not created after 'make'"
    exit 1
fi
echo "  PASS (libft.a created)"

# --- Test 2: No relink ---
echo "Test 2: No relinking (make twice)..."
MAKE_OUTPUT2=$(make 2>&1)
if echo "$MAKE_OUTPUT2" | grep -qE '(cc |gcc |ar )'; then
    echo "FAILED: Relinking detected! Running 'make' again should not recompile."
    echo "Output of second make:"
    echo "$MAKE_OUTPUT2"
    exit 1
fi
echo "  PASS (no relink)"

# --- Test 3: Library works ---
echo "Test 3: Library functionality..."
cat > test_main.c << 'TESTEOF'
#include "ft.h"

int	main(void)
{
	ft_putstr("OK");
	ft_putchar('\n');
	ft_putnbr(ft_strlen("hello"));
	ft_putchar('\n');
	return (0);
}
TESTEOF

cc -Wall -Wextra -Werror test_main.c libft.a -o test_prog 2>/dev/null
if [ $? -ne 0 ]; then
    cc -Wall -Wextra -Werror test_main.c -L. -lft -o test_prog 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "FAILED: Cannot link test program with libft.a"
        exit 1
    fi
fi

RESULT=$(./test_prog)
EXPECTED=$(printf 'OK\n5')
if [ "$RESULT" != "$EXPECTED" ]; then
    echo "FAILED: Library output mismatch"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$RESULT'"
    exit 1
fi
echo "  PASS"

# --- Test 4: make clean ---
echo "Test 4: make clean..."
make clean 2>&1 > /dev/null

# .o files should be gone
OBJ_COUNT=$(ls *.o 2>/dev/null | wc -l)
if [ "$OBJ_COUNT" -gt 0 ]; then
    echo "FAILED: .o files still present after 'make clean'"
    exit 1
fi

# libft.a should still exist after clean
if [ ! -f "libft.a" ]; then
    echo "FAILED: libft.a was deleted by 'make clean' (should only be deleted by fclean)"
    exit 1
fi
echo "  PASS (.o removed, libft.a preserved)"

# --- Test 5: make fclean ---
echo "Test 5: make fclean..."
make fclean 2>&1 > /dev/null

if [ -f "libft.a" ]; then
    echo "FAILED: libft.a still present after 'make fclean'"
    exit 1
fi
OBJ_COUNT=$(ls *.o 2>/dev/null | wc -l)
if [ "$OBJ_COUNT" -gt 0 ]; then
    echo "FAILED: .o files still present after 'make fclean'"
    exit 1
fi
echo "  PASS (all build artifacts removed)"

# --- Test 6: make re ---
echo "Test 6: make re..."
make re 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    echo "FAILED: 'make re' returned error"
    exit 1
fi
if [ ! -f "libft.a" ]; then
    echo "FAILED: libft.a not created after 'make re'"
    exit 1
fi
echo "  PASS (rebuild from scratch)"

# --- All passed ---
cd - > /dev/null
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
