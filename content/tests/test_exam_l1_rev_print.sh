#!/bin/bash
# test_exam_l1_rev_print.sh — hash verification
# Usage: bash test_exam_l1_rev_print.sh [source_dir]
set -e

EXERCISE_ID="exam_l1_rev_print"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 1: Print string in reverse)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/rev_print.c" ]; then
    echo "FAILED: File 'rev_print.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/rev_print.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in rev_print.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/rev_print.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/rev_print.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/rev_print.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

PASS=0
FAIL=0

# --- Test 1: Basic string ---
echo "Test 1: 'Hello World' -> 'dlroW olleH'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "Hello World")
EXPECTED="dlroW olleH"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 2: "42 Paris" ---
echo "Test 2: '42 Paris' -> 'siraP 24'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "42 Paris")
EXPECTED="siraP 24"
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

# --- Test 4: Empty string ---
echo "Test 4: Empty string..."
RESULT=$(/tmp/${EXERCISE_ID}_test "")
EXPECTED=""
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected empty, Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 5: Single character ---
echo "Test 5: Single character 'a'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "a")
EXPECTED="a"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 6: Palindrome ---
echo "Test 6: Palindrome 'abcba'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "abcba")
EXPECTED="abcba"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 7: Special characters ---
echo "Test 7: Special chars '!@#'..."
RESULT=$(/tmp/${EXERCISE_ID}_test '!@#')
EXPECTED='#@!'
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
echo "Code: $HASH"
exit 0
