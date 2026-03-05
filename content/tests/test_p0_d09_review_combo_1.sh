#!/bin/bash
# test_p0_d09_review_combo_1.sh — hash verification
# Usage: bash test_p0_d09_review_combo_1.sh [source_dir]
set -e

EXERCISE_ID="p0_d09_review_combo_1"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
for f in main.c ft_putchar.c ft_putstr.c ft_putnbr.c; do
    if [ ! -f "${SRC_DIR}/${f}" ]; then
        echo "FAILED: File '${f}' not found"
        exit 1
    fi
done

# Check for forbidden functions
for f in main.c ft_putchar.c ft_putstr.c ft_putnbr.c; do
    if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/main.c" "${SRC_DIR}/ft_putchar.c" \
    "${SRC_DIR}/ft_putstr.c" "${SRC_DIR}/ft_putnbr.c"
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

# Check for name line
if echo "$RESULT" | grep -q "Name: Maksym"; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Missing 'Name: Maksym'"
    PASS=0
fi
CHECKS=$((CHECKS + 1))

# Check for age line
if echo "$RESULT" | grep -q "Age: 17"; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Missing 'Age: 17'"
    PASS=0
fi
CHECKS=$((CHECKS + 1))

# Check for favorite letter
if echo "$RESULT" | grep -q "Favorite letter: M"; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Missing 'Favorite letter: M'"
    PASS=0
fi
CHECKS=$((CHECKS + 1))

# Check for status
if echo "$RESULT" | grep -q "Status: READY"; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Missing 'Status: READY'"
    PASS=0
fi
CHECKS=$((CHECKS + 1))

# Check for header
if echo "$RESULT" | grep -q "Student Card"; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Missing 'Student Card' header"
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
