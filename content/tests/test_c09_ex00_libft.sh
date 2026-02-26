#!/bin/bash
# test_c09_ex00_libft.sh — hash verification
# Usage: bash test_c09_ex00_libft.sh [source_dir]
set -e

EXERCISE_ID="c09_ex00_libft"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(C09 ex00: libft — create static library)"
echo ""

# Check source files exist
SRCS="ft_putchar.c ft_putstr.c ft_putnbr.c ft_strlen.c ft_strcmp.c ft_swap.c"
for SRC in $SRCS; do
    if [ ! -f "${SRC_DIR}/${SRC}" ]; then
        echo "FAILED: File '${SRC}' not found"
        exit 1
    fi
done

# Check header exists
if [ ! -f "${SRC_DIR}/ft.h" ]; then
    echo "FAILED: Header 'ft.h' not found"
    exit 1
fi

# Check header guards
if ! grep -q '#ifndef FT_H' "${SRC_DIR}/ft.h" 2>/dev/null; then
    echo "FAILED: Missing header guard (#ifndef FT_H) in ft.h"
    exit 1
fi

# Check for forbidden functions in all source files
for SRC in $SRCS; do
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${SRC_DIR}/${SRC}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${SRC} (printf/scanf/puts)"
        exit 1
    fi
    if grep -qE '\bfor\s*\(' "${SRC_DIR}/${SRC}" 2>/dev/null; then
        echo "FAILED: Forbidden 'for' loop in ${SRC} (use 'while')"
        exit 1
    fi
done

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    for SRC in $SRCS; do
        norminette "${SRC_DIR}/${SRC}" || {
            echo "FAILED: Norminette errors in ${SRC}"
            exit 1
        }
    done
    norminette "${SRC_DIR}/ft.h" || {
        echo "FAILED: Norminette errors in ft.h"
        exit 1
    }
fi

# --- Test 1: Compile .o files and create library ---
echo "Test 1: Building libft.a..."

TMPDIR=$(mktemp -d)
trap "rm -rf ${TMPDIR}" EXIT

for SRC in $SRCS; do
    cc -Wall -Wextra -Werror -I"${SRC_DIR}" -c "${SRC_DIR}/${SRC}" -o "${TMPDIR}/$(basename ${SRC} .c).o"
done

ar rcs "${TMPDIR}/libft.a" "${TMPDIR}"/*.o

# Verify archive contents
AR_CONTENTS=$(ar -t "${TMPDIR}/libft.a" | sort)
EXPECTED_CONTENTS=$(echo "ft_putchar.o ft_putstr.o ft_putnbr.o ft_strlen.o ft_strcmp.o ft_swap.o" | tr ' ' '\n' | sort)

if [ "$AR_CONTENTS" != "$EXPECTED_CONTENTS" ]; then
    echo "FAILED: Library contents mismatch"
    echo "Expected: $EXPECTED_CONTENTS"
    echo "Got: $AR_CONTENTS"
    exit 1
fi
echo "  PASS (library created with all .o files)"

# --- Test 2: Link and run test program ---
echo "Test 2: Linking test program with libft.a..."

cat > "${TMPDIR}/main_test.c" << 'TESTEOF'
#include "ft.h"

int	main(void)
{
	int	a;
	int	b;

	ft_putstr("Hello from libft!\n");
	ft_putnbr(ft_strlen("test"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abc", "abd"));
	ft_putchar('\n');
	a = 10;
	b = 20;
	ft_swap(&a, &b);
	ft_putnbr(a);
	ft_putchar(' ');
	ft_putnbr(b);
	ft_putchar('\n');
	return (0);
}
TESTEOF

cc -Wall -Wextra -Werror -I"${SRC_DIR}" "${TMPDIR}/main_test.c" "${TMPDIR}/libft.a" -o "${TMPDIR}/test_prog"
RESULT=$("${TMPDIR}/test_prog")
EXPECTED=$(printf 'Hello from libft!\n4\n-1\n20 10')

if [ "$RESULT" != "$EXPECTED" ]; then
    echo "FAILED: Output mismatch"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$RESULT'"
    exit 1
fi
echo "  PASS"

# --- Test 3: Individual function checks ---
echo "Test 3: Individual function verification..."

cat > "${TMPDIR}/main_test2.c" << 'TESTEOF'
#include "ft.h"

int	main(void)
{
	/* ft_putchar */
	ft_putchar('A');
	ft_putchar('\n');
	/* ft_strlen */
	ft_putnbr(ft_strlen(""));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("abcdefghij"));
	ft_putchar('\n');
	/* ft_strcmp */
	ft_putnbr(ft_strcmp("a", "a"));
	ft_putchar('\n');
	/* ft_putnbr edge */
	ft_putnbr(-42);
	ft_putchar('\n');
	ft_putnbr(0);
	ft_putchar('\n');
	return (0);
}
TESTEOF

cc -Wall -Wextra -Werror -I"${SRC_DIR}" "${TMPDIR}/main_test2.c" "${TMPDIR}/libft.a" -o "${TMPDIR}/test_prog2"
RESULT2=$("${TMPDIR}/test_prog2")
EXPECTED2=$(printf 'A\n0\n10\n0\n-42\n0')

if [ "$RESULT2" != "$EXPECTED2" ]; then
    echo "FAILED: Individual function checks"
    echo "Expected: '$EXPECTED2'"
    echo "Got:      '$RESULT2'"
    exit 1
fi
echo "  PASS"

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
