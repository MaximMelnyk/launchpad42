#!/bin/bash
# test_p0_d09_review_combo_2.sh — hash verification
# Usage: bash test_p0_d09_review_combo_2.sh [source_dir]
set -e

EXERCISE_ID="p0_d09_review_combo_2"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="

# Collect all .c files in source dir
C_FILES=$(ls "${SRC_DIR}"/*.c 2>/dev/null)
if [ -z "$C_FILES" ]; then
    echo "FAILED: No .c files found in ${SRC_DIR}"
    exit 1
fi

# Check for forbidden functions
for f in ${C_FILES}; do
    if grep -q 'printf\|scanf\|puts(' "$f" 2>/dev/null; then
        echo "FAILED: Forbidden function in $(basename $f) (printf/scanf/puts)"
        exit 1
    fi
done

# Check for forbidden for loops
for f in ${C_FILES}; do
    if grep -qE '\bfor\s*\(' "$f" 2>/dev/null; then
        echo "FAILED: Forbidden 'for' loop in $(basename $f) (use 'while')"
        exit 1
    fi
done

# Compile all .c files
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test ${C_FILES}
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

# Run and capture output
RESULT=$(/tmp/${EXERCISE_ID}_test)

# Verify key content
PASS=1
CHECKS=0
PASSED=0

# Check for PROFILE header
if echo "$RESULT" | grep -q "PROFILE"; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Missing 'PROFILE' header"
    PASS=0
fi
CHECKS=$((CHECKS + 1))

# Check for Name
if echo "$RESULT" | grep -q "Name: Maksym"; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Missing 'Name: Maksym'"
    PASS=0
fi
CHECKS=$((CHECKS + 1))

# Check for Level
if echo "$RESULT" | grep -q "Level:.*Init"; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Missing 'Level: 0 (Init)'"
    PASS=0
fi
CHECKS=$((CHECKS + 1))

# Check for progress bar
if echo "$RESULT" | grep -q '\[.*\]'; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Missing progress bar [###...]"
    PASS=0
fi
CHECKS=$((CHECKS + 1))

# Check for Verdict
if echo "$RESULT" | grep -q "Verdict:"; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Missing 'Verdict:'"
    PASS=0
fi
CHECKS=$((CHECKS + 1))

# Check for Days until Piscine
if echo "$RESULT" | grep -q "Days until Piscine:"; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Missing 'Days until Piscine:'"
    PASS=0
fi
CHECKS=$((CHECKS + 1))

if [ "$PASS" -eq 1 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED (${PASSED}/${CHECKS})"
    show_compile_count
    echo "Code: $HASH"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 0
else
    echo "FAILED (${PASSED}/${CHECKS} passed)"
    echo "Output was:"
    echo "$RESULT"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
