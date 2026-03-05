#!/bin/bash
# test_exam_l1_fizz_buzz.sh — hash verification
# Usage: bash test_exam_l1_fizz_buzz.sh [source_dir]
set -e

EXERCISE_ID="exam_l1_fizz_buzz"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 1: FizzBuzz 1-100)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/fizz_buzz.c" ]; then
    echo "FAILED: File 'fizz_buzz.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bputchar\b' "${SRC_DIR}/fizz_buzz.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in fizz_buzz.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/fizz_buzz.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/fizz_buzz.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "${SRC_DIR}/fizz_buzz.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

# Generate expected output
EXPECTED_FILE="/tmp/${EXERCISE_ID}_expected.txt"
python3 -c "
for i in range(1, 101):
    if i % 15 == 0:
        print('fizzbuzz')
    elif i % 3 == 0:
        print('fizz')
    elif i % 5 == 0:
        print('buzz')
    else:
        print(i)
" > "$EXPECTED_FILE"

PASS=0
FAIL=0

# --- Test 1: Full output comparison ---
echo "Test 1: Full FizzBuzz output..."
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED=$(cat "$EXPECTED_FILE")
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Output mismatch"
    echo "  First difference:"
    diff <(echo "$RESULT") <(echo "$EXPECTED") | head -5
    ((FAIL++))
fi

# --- Test 2: Line count (exactly 100 lines) ---
echo "Test 2: Line count..."
LINE_COUNT=$(/tmp/${EXERCISE_ID}_test | wc -l)
if [ "$LINE_COUNT" -eq 100 ]; then
    echo "  PASS"
    ((PASS++))
else
    echo "  FAIL: Expected 100 lines, got $LINE_COUNT"
    ((FAIL++))
fi

# --- Test 3: Spot check specific values ---
echo "Test 3: Spot checks (line 3=fizz, 5=buzz, 15=fizzbuzz, 7=7)..."
LINE3=$(/tmp/${EXERCISE_ID}_test | sed -n '3p')
LINE5=$(/tmp/${EXERCISE_ID}_test | sed -n '5p')
LINE15=$(/tmp/${EXERCISE_ID}_test | sed -n '15p')
LINE7=$(/tmp/${EXERCISE_ID}_test | sed -n '7p')
LINE100=$(/tmp/${EXERCISE_ID}_test | sed -n '100p')

SPOT_PASS=true
if [ "$LINE3" != "fizz" ]; then echo "  Line 3: Expected 'fizz', got '$LINE3'"; SPOT_PASS=false; fi
if [ "$LINE5" != "buzz" ]; then echo "  Line 5: Expected 'buzz', got '$LINE5'"; SPOT_PASS=false; fi
if [ "$LINE15" != "fizzbuzz" ]; then echo "  Line 15: Expected 'fizzbuzz', got '$LINE15'"; SPOT_PASS=false; fi
if [ "$LINE7" != "7" ]; then echo "  Line 7: Expected '7', got '$LINE7'"; SPOT_PASS=false; fi
if [ "$LINE100" != "buzz" ]; then echo "  Line 100: Expected 'buzz', got '$LINE100'"; SPOT_PASS=false; fi

if [ "$SPOT_PASS" = true ]; then
    echo "  PASS"
    ((PASS++))
else
    ((FAIL++))
fi

rm -f /tmp/${EXERCISE_ID}_test "$EXPECTED_FILE"

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
