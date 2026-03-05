#!/bin/bash
# test_exam_l1_ulstr.sh — hash verification
# Usage: bash test_exam_l1_ulstr.sh [source_dir]
set -e

EXERCISE_ID="exam_l1_ulstr"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 1: Swap case uppercase/lowercase)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ulstr.c" ]; then
    echo "FAILED: File 'ulstr.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b|\btoupper\b|\btolower\b' "${SRC_DIR}/ulstr.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ulstr.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ulstr.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ulstr.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/ulstr.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

PASS=0
FAIL=0

# --- Test 1: Basic swap ---
echo "Test 1: 'Hello World' -> 'hELLO wORLD'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "Hello World")
EXPECTED="hELLO wORLD"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 2: Mixed with numbers ---
echo "Test 2: \"L'eSPrit 42\" -> \"l'EspRIT 42\"..."
RESULT=$(/tmp/${EXERCISE_ID}_test "L'eSPrit 42")
EXPECTED="l'EspRIT 42"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 3: No arguments ---
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

# --- Test 4: All lowercase ---
echo "Test 4: 'abcxyz' -> 'ABCXYZ'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "abcxyz")
EXPECTED="ABCXYZ"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 5: All uppercase ---
echo "Test 5: 'ABCXYZ' -> 'abcxyz'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "ABCXYZ")
EXPECTED="abcxyz"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 6: Only non-alpha ---
echo "Test 6: '123!@#' -> '123!@#'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "123!@#")
EXPECTED="123!@#"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 7: Empty string ---
echo "Test 7: Empty string..."
RESULT=$(/tmp/${EXERCISE_ID}_test "")
EXPECTED=""
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected empty, Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 8: Single char ---
echo "Test 8: 'a' -> 'A'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "a")
EXPECTED="A"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
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
    show_compile_count
echo "Code: $HASH"
exit 0
