#!/bin/bash
# test_exam_l0_aff_first_param.sh — hash verification
# Usage: bash test_exam_l0_aff_first_param.sh [source_dir]
set -e

EXERCISE_ID="exam_l0_aff_first_param"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 0: Print first argument)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/aff_first_param.c" ]; then
    echo "FAILED: File 'aff_first_param.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/aff_first_param.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in aff_first_param.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/aff_first_param.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/aff_first_param.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/aff_first_param.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

PASS=0
FAIL=0

# --- Test 1: Single argument ---
echo "Test 1: Single argument..."
RESULT=$(/tmp/${EXERCISE_ID}_test "Hello World")
EXPECTED="Hello World"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 2: Multiple arguments (should print first only) ---
echo "Test 2: Multiple arguments..."
RESULT=$(/tmp/${EXERCISE_ID}_test "Piscine42" "Bonus")
EXPECTED="Piscine42"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 3: No arguments (just newline) ---
echo "Test 3: No arguments..."
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=""
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected empty, Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 4: Argument with special chars ---
echo "Test 4: Special characters..."
RESULT=$(/tmp/${EXERCISE_ID}_test "42!@#\$%")
EXPECTED='42!@#$%'
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 5: Empty string argument ---
echo "Test 5: Empty string argument..."
RESULT=$(/tmp/${EXERCISE_ID}_test "")
EXPECTED=""
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected empty, Got '$RESULT'"
    ((FAIL++))
fi

rm -f /tmp/${EXERCISE_ID}_test

if [ $FAIL -ne 0 ]; then
    echo ""
    echo "TESTS FAILED: $FAIL failed, $PASS passed"
    exit 1
fi

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
