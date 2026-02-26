#!/bin/bash
# test_rush01_skyscraper.sh — hash verification
# Usage: bash test_rush01_skyscraper.sh [source_dir]
set -e

EXERCISE_ID="rush01_skyscraper"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Rush01: Skyscraper 4x4 — backtracking solver)"
echo ""

# Check for at least one source file
C_FILES=$(find "${SRC_DIR}" -maxdepth 1 -name "*.c" 2>/dev/null | head -20)
if [ -z "$C_FILES" ]; then
    echo "FAILED: No .c files found in ${SRC_DIR}"
    exit 1
fi

# Check for forbidden functions in all source files
for SRC in $C_FILES; do
    BASENAME=$(basename "$SRC")
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "$SRC" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${BASENAME} (printf/scanf/puts)"
        exit 1
    fi
    if grep -qE '\bfor\s*\(' "$SRC" 2>/dev/null; then
        echo "FAILED: Forbidden 'for' loop in ${BASENAME} (use 'while')"
        exit 1
    fi
    if grep -qE '\bexit\s*\(' "$SRC" 2>/dev/null; then
        echo "FAILED: Forbidden 'exit' in ${BASENAME}"
        exit 1
    fi
done

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    for SRC in $C_FILES; do
        norminette "$SRC" || {
            echo "FAILED: Norminette errors in $(basename $SRC)"
            exit 1
        }
    done
fi

# --- Compile ---
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test $C_FILES
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi
echo "  Compilation OK"

# --- Test 1: Known valid puzzle ---
echo "Test 1: Known valid puzzle..."
RESULT1=$(/tmp/${EXERCISE_ID}_test "4 3 2 1 1 2 2 2 4 3 2 1 1 2 2 2" 2>&1)
EXPECTED1=$(printf '1 2 3 4\n2 3 4 1\n3 4 1 2\n4 1 2 3')

if [ "$RESULT1" != "$EXPECTED1" ]; then
    echo "FAILED: Known puzzle output mismatch"
    echo "Expected:"
    echo "$EXPECTED1"
    echo "Got:"
    echo "$RESULT1"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 2: Another valid puzzle ---
echo "Test 2: Another valid puzzle..."
RESULT2=$(/tmp/${EXERCISE_ID}_test "1 2 2 2 2 2 2 1 1 2 2 2 2 2 2 1" 2>&1)

# Verify it's a valid 4x4 grid (4 lines, each with 4 numbers 1-4)
LINE_COUNT=$(echo "$RESULT2" | wc -l)
if [ "$LINE_COUNT" -ne 4 ]; then
    echo "FAILED: Expected 4 lines, got $LINE_COUNT"
    echo "Output: '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi

# Check each line has format "N N N N" with digits 1-4
VALID=1
while IFS= read -r line; do
    if ! echo "$line" | grep -qE '^[1-4] [1-4] [1-4] [1-4]$'; then
        VALID=0
        break
    fi
done <<< "$RESULT2"

if [ "$VALID" -eq 0 ]; then
    echo "FAILED: Invalid grid format"
    echo "Output: '$RESULT2'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS (valid 4x4 grid)"

# --- Test 3: Invalid input — no solution ---
echo "Test 3: No solution (should print Error)..."
RESULT3=$(/tmp/${EXERCISE_ID}_test "1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1" 2>&1)
if [ "$RESULT3" != "Error" ]; then
    echo "FAILED: Expected 'Error' for unsolvable puzzle"
    echo "Got: '$RESULT3'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 4: No arguments ---
echo "Test 4: No arguments (should print Error)..."
RESULT4=$(/tmp/${EXERCISE_ID}_test 2>&1)
if [ "$RESULT4" != "Error" ]; then
    echo "FAILED: Expected 'Error' for no arguments"
    echo "Got: '$RESULT4'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 5: Wrong format ---
echo "Test 5: Wrong format (should print Error)..."
RESULT5=$(/tmp/${EXERCISE_ID}_test "1 2 3" 2>&1)
if [ "$RESULT5" != "Error" ]; then
    echo "FAILED: Expected 'Error' for incomplete input"
    echo "Got: '$RESULT5'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

# --- Test 6: Invalid values (out of range) ---
echo "Test 6: Invalid values (should print Error)..."
RESULT6=$(/tmp/${EXERCISE_ID}_test "5 3 2 1 1 2 2 2 4 3 2 1 1 2 2 2" 2>&1)
if [ "$RESULT6" != "Error" ]; then
    echo "FAILED: Expected 'Error' for out-of-range values"
    echo "Got: '$RESULT6'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
echo "  PASS"

rm -f /tmp/${EXERCISE_ID}_test

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
