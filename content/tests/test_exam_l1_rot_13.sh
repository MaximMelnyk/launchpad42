#!/bin/bash
# test_exam_l1_rot_13.sh — hash verification
# Usage: bash test_exam_l1_rot_13.sh [source_dir]
set -e

EXERCISE_ID="exam_l1_rot_13"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 1: ROT13 cipher)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/rot_13.c" ]; then
    echo "FAILED: File 'rot_13.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/rot_13.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in rot_13.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/rot_13.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/rot_13.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/rot_13.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

PASS=0
FAIL=0

# --- Test 1: "abc" -> "nop" ---
echo "Test 1: 'abc' -> 'nop'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "abc")
EXPECTED="nop"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 2: "Hello, World!" -> "Uryyb, Jbeyq!" ---
echo "Test 2: 'Hello, World!' -> 'Uryyb, Jbeyq!'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "Hello, World!")
EXPECTED="Uryyb, Jbeyq!"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 3: Double ROT13 = original ---
echo "Test 3: Double ROT13 = original..."
RESULT=$(/tmp/${EXERCISE_ID}_test "Uryyb, Jbeyq!")
EXPECTED="Hello, World!"
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

# --- Test 5: Non-alpha chars unchanged ---
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

# --- Test 6: Full lowercase alphabet ---
echo "Test 6: Full lowercase alphabet..."
RESULT=$(/tmp/${EXERCISE_ID}_test "abcdefghijklmnopqrstuvwxyz")
EXPECTED="nopqrstuvwxyzabcdefghijklm"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 7: Full uppercase alphabet ---
echo "Test 7: Full uppercase alphabet..."
RESULT=$(/tmp/${EXERCISE_ID}_test "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
EXPECTED="NOPQRSTUVWXYZABCDEFGHIJKLM"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 8: Empty string ---
echo "Test 8: Empty string..."
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
