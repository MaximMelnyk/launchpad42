#!/bin/bash
# test_exam_l1_first_word.sh — hash verification
# Usage: bash test_exam_l1_first_word.sh [source_dir]
set -e

EXERCISE_ID="exam_l1_first_word"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 1: Print first word of argv[1])"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/first_word.c" ]; then
    echo "FAILED: File 'first_word.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/first_word.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in first_word.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/first_word.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/first_word.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/first_word.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

PASS=0
FAIL=0

# --- Test 1: Normal sentence ---
echo "Test 1: Normal sentence..."
RESULT=$(/tmp/${EXERCISE_ID}_test "hello world")
EXPECTED="hello"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 2: Leading spaces ---
echo "Test 2: Leading spaces..."
RESULT=$(/tmp/${EXERCISE_ID}_test "  hello world  ")
EXPECTED="hello"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 3: Leading tabs and spaces ---
echo "Test 3: Leading tabs and spaces..."
RESULT=$(/tmp/${EXERCISE_ID}_test "$(printf '\t  \t easy   stuff  ')")
EXPECTED="easy"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 4: Single word ---
echo "Test 4: Single word..."
RESULT=$(/tmp/${EXERCISE_ID}_test "piscine42")
EXPECTED="piscine42"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 5: No arguments ---
echo "Test 5: No arguments..."
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=""
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected empty, Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 6: Only spaces ---
echo "Test 6: Only spaces..."
RESULT=$(/tmp/${EXERCISE_ID}_test "     ")
EXPECTED=""
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected empty, Got '$RESULT'"
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
