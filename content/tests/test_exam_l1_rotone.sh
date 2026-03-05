#!/bin/bash
# test_exam_l1_rotone.sh — hash verification
# Usage: bash test_exam_l1_rotone.sh [source_dir]
set -e

EXERCISE_ID="exam_l1_rotone"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 1: ROT1 cipher)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/rotone.c" ]; then
    echo "FAILED: File 'rotone.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/rotone.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in rotone.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/rotone.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/rotone.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/rotone.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

PASS=0
FAIL=0

# --- Test 1: "abc" -> "bcd" ---
echo "Test 1: 'abc' -> 'bcd'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "abc")
EXPECTED="bcd"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 2: Wrap around "zZ" -> "aA" ---
echo "Test 2: 'zZ' -> 'aA'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "zZ")
EXPECTED="aA"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 3: "Hello, World!" -> "Ifmmp, Xpsme!" ---
echo "Test 3: 'Hello, World!' -> 'Ifmmp, Xpsme!'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "Hello, World!")
EXPECTED="Ifmmp, Xpsme!"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 4: No arguments ---
echo "Test 4: No arguments..."
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=""
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected empty, Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 5: Non-alpha unchanged ---
echo "Test 5: Non-alpha unchanged '123!@#'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "123!@#")
EXPECTED="123!@#"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 6: Full alphabet ---
echo "Test 6: Full lowercase alphabet..."
RESULT=$(/tmp/${EXERCISE_ID}_test "abcdefghijklmnopqrstuvwxyz")
EXPECTED="bcdefghijklmnopqrstuvwxyza"
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
