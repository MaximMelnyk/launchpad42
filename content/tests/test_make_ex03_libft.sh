#!/bin/bash
# test_make_ex03_libft.sh — hash verification
# Usage: bash test_make_ex03_libft.sh [source_dir]
set -e

EXERCISE_ID="make_ex03_libft"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

PASS=0
FAIL=0

cd "$SRC_DIR"

# Test 1: Makefile exists
if [ -f "Makefile" ]; then
    echo "PASS: Makefile exists"
    ((PASS++))
else
    echo "FAIL: Makefile not found"
    ((FAIL++))
    echo "TESTS FAILED ($PASS passed, $FAIL failed)"
    exit 1
fi

# Test 2: Source files exist
for f in ft_putchar.c ft_putstr.c ft_strlen.c ft_swap.c; do
    if [ -f "$f" ]; then
        echo "PASS: $f exists"
        ((PASS++))
    else
        echo "FAIL: $f not found"
        ((FAIL++))
    fi
done

# Test 3: Check for forbidden functions
for f in ft_putchar.c ft_putstr.c ft_strlen.c ft_swap.c; do
    if [ -f "$f" ] && grep -q 'printf\|scanf\|puts(' "$f" 2>/dev/null; then
        echo "FAIL: Forbidden function in $f (printf/scanf/puts)"
        ((FAIL++))
    fi
done

# Test 4: Makefile NAME is libft.a
NAME_VAL=$(grep '^NAME' Makefile | head -1 | sed 's/NAME[[:space:]]*=[[:space:]]*//')
if [ "$NAME_VAL" == "libft.a" ]; then
    echo "PASS: NAME = libft.a"
    ((PASS++))
else
    echo "FAIL: NAME should be 'libft.a', got '$NAME_VAL'"
    ((FAIL++))
fi

# Test 5: Makefile uses 'ar' command
if grep -q 'ar' Makefile 2>/dev/null; then
    echo "PASS: Makefile uses 'ar' for archiving"
    ((PASS++))
else
    echo "FAIL: Makefile does not use 'ar' command"
    ((FAIL++))
fi

# Test 6: Makefile has all required targets
for target in "all:" "clean:" "fclean:" "re:"; do
    if grep -q "^${target}" Makefile 2>/dev/null; then
        echo "PASS: Makefile has target '$target'"
        ((PASS++))
    else
        echo "FAIL: Makefile missing target '$target'"
        ((FAIL++))
    fi
done

# Test 7: .PHONY declared
if grep -q '\.PHONY' Makefile 2>/dev/null; then
    echo "PASS: .PHONY declared"
    ((PASS++))
else
    echo "FAIL: .PHONY missing"
    ((FAIL++))
fi

# Test 8: Makefile uses SRC and OBJ variables
for var in SRC OBJ; do
    if grep -q "^${var}" Makefile 2>/dev/null; then
        echo "PASS: Makefile defines $var"
        ((PASS++))
    else
        echo "FAIL: Makefile missing $var variable"
        ((FAIL++))
    fi
done

# Clean before tests
make fclean > /dev/null 2>&1 || rm -f libft.a *.o

# Test 9: 'make' creates libft.a
MAKE_OUTPUT=$(make 2>&1)
MAKE_STATUS=$?
if [ $MAKE_STATUS -eq 0 ]; then
    echo "PASS: 'make' succeeds"
    ((PASS++))
else
    echo "FAIL: 'make' failed:"
    echo "  $MAKE_OUTPUT"
    ((FAIL++))
fi

# Test 10: libft.a is a valid archive
if [ -f "libft.a" ]; then
    if file libft.a | grep -q "archive\|ar archive"; then
        echo "PASS: libft.a is a valid archive"
        ((PASS++))
    else
        echo "FAIL: libft.a is not a valid archive"
        ((FAIL++))
    fi
else
    echo "FAIL: libft.a not created"
    ((FAIL++))
fi

# Test 11: libft.a contains expected object files
if [ -f "libft.a" ]; then
    AR_CONTENTS=$(ar -t libft.a 2>/dev/null)
    EXPECTED_OBJS="ft_putchar.o ft_putstr.o ft_strlen.o ft_swap.o"
    ALL_FOUND=true
    for obj in $EXPECTED_OBJS; do
        if echo "$AR_CONTENTS" | grep -q "$obj"; then
            true
        else
            ALL_FOUND=false
            echo "FAIL: libft.a missing $obj"
            ((FAIL++))
        fi
    done
    if [ "$ALL_FOUND" = true ]; then
        echo "PASS: libft.a contains all expected objects"
        ((PASS++))
    fi
fi

# Test 12: No relinking
MAKE_AGAIN=$(make 2>&1)
if echo "$MAKE_AGAIN" | grep -qi "up to date\|nothing to be done"; then
    echo "PASS: No relinking on second 'make'"
    ((PASS++))
else
    echo "FAIL: Relinked on second 'make'"
    ((FAIL++))
fi

# Test 13: Library can be linked and used
cat > /tmp/${EXERCISE_ID}_test_main.c << 'TESTEOF'
void	ft_putstr(char *str);
int		ft_strlen(char *str);

int	main(void)
{
	char	*msg;

	msg = "libft works!\n";
	ft_putstr(msg);
	return (0);
}
TESTEOF

if gcc -Wall -Wextra -Werror /tmp/${EXERCISE_ID}_test_main.c -L. -lft -o /tmp/${EXERCISE_ID}_test 2>/dev/null; then
    RESULT=$(/tmp/${EXERCISE_ID}_test 2>&1)
    if [ "$RESULT" == "libft works!" ]; then
        echo "PASS: Library links and produces correct output"
        ((PASS++))
    else
        echo "FAIL: Expected 'libft works!', got '$RESULT'"
        ((FAIL++))
    fi
    rm -f /tmp/${EXERCISE_ID}_test
else
    echo "FAIL: Could not link test program with libft.a"
    ((FAIL++))
fi
rm -f /tmp/${EXERCISE_ID}_test_main.c

# Test 14: 'make clean' removes .o but keeps libft.a
make clean > /dev/null 2>&1
O_AFTER_CLEAN=$(ls *.o 2>/dev/null | wc -l)
if [ "$O_AFTER_CLEAN" -eq 0 ] && [ -f "libft.a" ]; then
    echo "PASS: 'make clean' removed .o but kept libft.a"
    ((PASS++))
else
    if [ "$O_AFTER_CLEAN" -gt 0 ]; then
        echo "FAIL: 'make clean' did not remove .o files"
        ((FAIL++))
    fi
    if [ ! -f "libft.a" ]; then
        echo "FAIL: 'make clean' removed libft.a (should only remove .o)"
        ((FAIL++))
    fi
fi

# Test 15: 'make fclean' removes libft.a
make fclean > /dev/null 2>&1
if [ ! -f "libft.a" ]; then
    echo "PASS: 'make fclean' removed libft.a"
    ((PASS++))
else
    echo "FAIL: 'make fclean' did not remove libft.a"
    ((FAIL++))
fi

# Test 16: 'make re' rebuilds
if make re > /dev/null 2>&1 && [ -f "libft.a" ]; then
    echo "PASS: 'make re' rebuilds libft.a"
    ((PASS++))
else
    echo "FAIL: 'make re' failed"
    ((FAIL++))
fi

# Clean up
make fclean > /dev/null 2>&1 || rm -f libft.a *.o

# Result
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -eq 0 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    echo "Code: $HASH"
    exit 0
else
    echo "TESTS FAILED"
    exit 1
fi
