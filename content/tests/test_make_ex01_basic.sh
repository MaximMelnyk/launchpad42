#!/bin/bash
# test_make_ex01_basic.sh — hash verification
# Usage: bash test_make_ex01_basic.sh [source_dir]
set -e

EXERCISE_ID="make_ex01_basic"
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
for f in ft_putchar.c ft_putstr.c main.c; do
    if [ -f "$f" ]; then
        echo "PASS: $f exists"
        ((PASS++))
    else
        echo "FAIL: $f not found"
        ((FAIL++))
    fi
done

# Test 3: Check for forbidden functions in C files
for f in ft_putchar.c ft_putstr.c main.c; do
    if [ -f "$f" ] && grep -q 'printf\|scanf\|puts(' "$f" 2>/dev/null; then
        echo "FAIL: Forbidden function in $f (printf/scanf/puts)"
        ((FAIL++))
    fi
done

# Test 4: Makefile contains required variables
for var in NAME CC CFLAGS SRC; do
    if grep -q "^${var}" Makefile 2>/dev/null; then
        echo "PASS: Makefile defines $var"
        ((PASS++))
    else
        echo "FAIL: Makefile missing $var variable"
        ((FAIL++))
    fi
done

# Test 5: Makefile has .PHONY
if grep -q '\.PHONY' Makefile 2>/dev/null; then
    echo "PASS: Makefile has .PHONY declaration"
    ((PASS++))
else
    echo "FAIL: Makefile missing .PHONY"
    ((FAIL++))
fi

# Test 6: Makefile uses tabs (not spaces) for recipes
if grep -P '^\t' Makefile > /dev/null 2>&1; then
    echo "PASS: Makefile uses tabs for recipes"
    ((PASS++))
else
    echo "FAIL: Makefile may be using spaces instead of tabs"
    ((FAIL++))
fi

# Clean before test
make fclean > /dev/null 2>&1 || rm -f hello *.o

# Test 7: 'make' compiles successfully
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

# Test 8: Executable is created
NAME_VAL=$(grep '^NAME' Makefile | head -1 | sed 's/NAME[[:space:]]*=[[:space:]]*//')
if [ -z "$NAME_VAL" ]; then
    NAME_VAL="hello"
fi

if [ -f "$NAME_VAL" ] && [ -x "$NAME_VAL" ]; then
    echo "PASS: Executable '$NAME_VAL' created"
    ((PASS++))
else
    echo "FAIL: Executable '$NAME_VAL' not found or not executable"
    ((FAIL++))
fi

# Test 9: Executable produces correct output
if [ -f "$NAME_VAL" ]; then
    RESULT=$(./"$NAME_VAL" 2>&1)
    if [ "$RESULT" == "Hello from Makefile!" ]; then
        echo "PASS: Output is correct"
        ((PASS++))
    else
        echo "FAIL: Expected 'Hello from Makefile!', got '$RESULT'"
        ((FAIL++))
    fi
fi

# Test 10: 'make' again shows up-to-date
MAKE_AGAIN=$(make 2>&1)
if echo "$MAKE_AGAIN" | grep -qi "up to date\|nothing to be done"; then
    echo "PASS: 'make' again shows up-to-date (no relinking)"
    ((PASS++))
else
    echo "FAIL: 'make' recompiled (possible relinking issue)"
    ((FAIL++))
fi

# Test 11: CFLAGS includes -Wall -Wextra -Werror
if grep -q '\-Wall' Makefile && grep -q '\-Wextra' Makefile && grep -q '\-Werror' Makefile; then
    echo "PASS: CFLAGS includes -Wall -Wextra -Werror"
    ((PASS++))
else
    echo "FAIL: CFLAGS missing required flags"
    ((FAIL++))
fi

# Clean up
make fclean > /dev/null 2>&1 || rm -f "$NAME_VAL" *.o

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
