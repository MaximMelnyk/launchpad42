#!/bin/bash
# test_exam_l1_repeat_alpha.sh — hash verification
# Usage: bash test_exam_l1_repeat_alpha.sh [source_dir]
set -e

EXERCISE_ID="exam_l1_repeat_alpha"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 1: Repeat alpha characters)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/repeat_alpha.c" ]; then
    echo "FAILED: File 'repeat_alpha.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/repeat_alpha.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in repeat_alpha.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/repeat_alpha.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/repeat_alpha.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/repeat_alpha.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

PASS=0
FAIL=0

# --- Test 1: "abc" -> "abbccc" ---
echo "Test 1: 'abc' -> 'abbccc'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "abc")
EXPECTED="abbccc"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 2: "a!b" -> "a!bb" ---
echo "Test 2: 'a!b' -> 'a!bb'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "a!b")
EXPECTED="a!bb"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 3: "Z" -> 26 Z's ---
echo "Test 3: 'Z' -> 26 Z's..."
RESULT=$(/tmp/${EXERCISE_ID}_test "Z")
EXPECTED="ZZZZZZZZZZZZZZZZZZZZZZZZZZ"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected 26 Z's, Got '$RESULT' (length: ${#RESULT})"
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

# --- Test 5: "A1B" -> "A1BB" ---
echo "Test 5: 'A1B' -> 'A1BB'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "A1B")
EXPECTED="A1BB"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 6: "z" -> 26 z's ---
echo "Test 6: 'z' -> 26 z's..."
RESULT=$(/tmp/${EXERCISE_ID}_test "z")
EXPECTED="zzzzzzzzzzzzzzzzzzzzzzzzzz"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected 26 z's, Got '$RESULT' (length: ${#RESULT})"
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

# --- Test 8: Non-alpha chars only ---
echo "Test 8: '123!' -> '123!'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "123!")
EXPECTED="123!"
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
