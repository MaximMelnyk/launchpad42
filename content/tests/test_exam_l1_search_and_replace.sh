#!/bin/bash
# test_exam_l1_search_and_replace.sh — hash verification
# Usage: bash test_exam_l1_search_and_replace.sh [source_dir]
set -e

EXERCISE_ID="exam_l1_search_and_replace"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 1: Search and replace char)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/search_and_replace.c" ]; then
    echo "FAILED: File 'search_and_replace.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/search_and_replace.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in search_and_replace.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/search_and_replace.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/search_and_replace.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/search_and_replace.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

PASS=0
FAIL=0

# --- Test 1: Basic replacement ---
echo "Test 1: 'Hallo World' a e -> 'Hello World'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "Hallo World" "a" "e")
EXPECTED="Hello World"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 2: Multiple replacements ---
echo "Test 2: 'abcabc' a z -> 'zbczbc'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "abcabc" "a" "z")
EXPECTED="zbczbc"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 3: Char not found ---
echo "Test 3: 'hello' x y -> 'hello'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "hello" "x" "y")
EXPECTED="hello"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 4: Wrong argc (too many) ---
echo "Test 4: Wrong argc (too many)..."
RESULT=$(/tmp/${EXERCISE_ID}_test "too many" "a" "b" "c")
EXPECTED=""
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected empty, Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 5: Wrong argc (too few) ---
echo "Test 5: Wrong argc (too few)..."
RESULT=$(/tmp/${EXERCISE_ID}_test "hello")
EXPECTED=""
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected empty, Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 6: No arguments ---
echo "Test 6: No arguments..."
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=""
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected empty, Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 7: argv[2] not single char ---
echo "Test 7: argv[2] is multi-char..."
RESULT=$(/tmp/${EXERCISE_ID}_test "hello" "ab" "z")
EXPECTED=""
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected empty, Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 8: argv[3] not single char ---
echo "Test 8: argv[3] is multi-char..."
RESULT=$(/tmp/${EXERCISE_ID}_test "hello" "a" "zz")
EXPECTED=""
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected empty, Got '$RESULT'"
    ((FAIL++))
fi

# --- Test 9: Same char replace ---
echo "Test 9: Same char 'aaa' a a -> 'aaa'..."
RESULT=$(/tmp/${EXERCISE_ID}_test "aaa" "a" "a")
EXPECTED="aaa"
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
