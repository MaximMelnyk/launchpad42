#!/bin/bash
# test_make_ex02_full.sh — hash verification
# Usage: bash test_make_ex02_full.sh [source_dir]
set -e

EXERCISE_ID="make_ex02_full"
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
for f in ft_putchar.c ft_strlen.c ft_putstr.c main.c; do
    if [ -f "$f" ]; then
        echo "PASS: $f exists"
        ((PASS++))
    else
        echo "FAIL: $f not found"
        ((FAIL++))
    fi
done

# Test 3: Check for forbidden functions
for f in ft_putchar.c ft_strlen.c ft_putstr.c main.c; do
    if [ -f "$f" ] && grep -q 'printf\|scanf\|puts(' "$f" 2>/dev/null; then
        echo "FAIL: Forbidden function in $f (printf/scanf/puts)"
        ((FAIL++))
    fi
done

# Test 4: Makefile contains required variables
for var in NAME CC CFLAGS SRC OBJ; do
    if grep -q "^${var}" Makefile 2>/dev/null; then
        echo "PASS: Makefile defines $var"
        ((PASS++))
    else
        echo "FAIL: Makefile missing $var variable"
        ((FAIL++))
    fi
done

# Test 5: Makefile has all required targets
for target in "all:" "clean:" "fclean:" "re:"; do
    if grep -q "^${target}" Makefile 2>/dev/null; then
        echo "PASS: Makefile has target '$target'"
        ((PASS++))
    else
        echo "FAIL: Makefile missing target '$target'"
        ((FAIL++))
    fi
done

# Test 6: .PHONY includes all targets
if grep -q '\.PHONY.*all.*clean.*fclean.*re' Makefile 2>/dev/null || \
   (grep -q '\.PHONY' Makefile && grep '\.PHONY' Makefile | grep -q 'all' && \
    grep '\.PHONY' Makefile | grep -q 'clean' && grep '\.PHONY' Makefile | grep -q 're'); then
    echo "PASS: .PHONY declared for targets"
    ((PASS++))
else
    echo "FAIL: .PHONY missing or incomplete"
    ((FAIL++))
fi

# Clean before tests
make fclean > /dev/null 2>&1 || rm -f megaphone *.o

# Get NAME from Makefile
NAME_VAL=$(grep '^NAME' Makefile | head -1 | sed 's/NAME[[:space:]]*=[[:space:]]*//')
if [ -z "$NAME_VAL" ]; then
    NAME_VAL="megaphone"
fi

# Test 7: 'make' compiles via .o files
MAKE_OUTPUT=$(make 2>&1)
MAKE_STATUS=$?
if [ $MAKE_STATUS -eq 0 ]; then
    echo "PASS: 'make' succeeds"
    ((PASS++))
else
    echo "FAIL: 'make' failed"
    ((FAIL++))
fi

# Test 8: .o files were created (compiled via object files)
O_COUNT=$(ls *.o 2>/dev/null | wc -l)
if [ "$O_COUNT" -ge 2 ]; then
    echo "PASS: Object files created ($O_COUNT .o files)"
    ((PASS++))
else
    echo "FAIL: No .o files found (must compile via object files)"
    ((FAIL++))
fi

# Test 9: Executable created and works
if [ -f "$NAME_VAL" ] && [ -x "$NAME_VAL" ]; then
    RESULT=$(./"$NAME_VAL" 2>&1)
    if [ "$RESULT" == "Makefile works!" ]; then
        echo "PASS: Executable output correct"
        ((PASS++))
    else
        echo "FAIL: Expected 'Makefile works!', got '$RESULT'"
        ((FAIL++))
    fi
else
    echo "FAIL: Executable '$NAME_VAL' not found"
    ((FAIL++))
fi

# Test 10: No relinking — 'make' again is up-to-date
MAKE_AGAIN=$(make 2>&1)
if echo "$MAKE_AGAIN" | grep -qi "up to date\|nothing to be done"; then
    echo "PASS: No relinking on second 'make'"
    ((PASS++))
else
    echo "FAIL: Relinked on second 'make' (should be up-to-date)"
    ((FAIL++))
fi

# Test 11: 'make clean' removes .o files
make clean > /dev/null 2>&1
O_AFTER_CLEAN=$(ls *.o 2>/dev/null | wc -l)
if [ "$O_AFTER_CLEAN" -eq 0 ]; then
    echo "PASS: 'make clean' removed all .o files"
    ((PASS++))
else
    echo "FAIL: 'make clean' did not remove .o files ($O_AFTER_CLEAN remain)"
    ((FAIL++))
fi

# Test 12: 'make clean' does NOT remove executable
if [ -f "$NAME_VAL" ]; then
    echo "PASS: 'make clean' kept executable"
    ((PASS++))
else
    echo "FAIL: 'make clean' removed executable (should only remove .o)"
    ((FAIL++))
fi

# Test 13: 'make fclean' removes executable
make fclean > /dev/null 2>&1
if [ ! -f "$NAME_VAL" ]; then
    echo "PASS: 'make fclean' removed executable"
    ((PASS++))
else
    echo "FAIL: 'make fclean' did not remove executable"
    ((FAIL++))
fi

# Test 14: 'make re' recompiles everything
MAKE_RE_OUTPUT=$(make re 2>&1)
if [ $? -eq 0 ] && [ -f "$NAME_VAL" ]; then
    echo "PASS: 'make re' recompiled successfully"
    ((PASS++))
else
    echo "FAIL: 'make re' failed"
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
