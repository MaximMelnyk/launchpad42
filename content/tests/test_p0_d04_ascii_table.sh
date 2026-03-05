#!/bin/bash
# test_p0_d04_ascii_table.sh — hash verification
# Usage: bash test_p0_d04_ascii_table.sh [source_dir]
set -e

EXERCISE_ID="p0_d04_ascii_table"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source files exist
for f in main.c ft_putchar.c ft_putnbr.c ft_putstr.c; do
    if [ ! -f "${SRC_DIR}/${f}" ]; then
        echo "FAILED: File '${f}' not found"
        exit 1
    fi
done

# Check for forbidden functions
for f in main.c ft_putchar.c ft_putnbr.c ft_putstr.c; do
    if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/${f}" 2>/dev/null; then
        echo "FAILED: Forbidden function in ${f} (printf/scanf/puts)"
        exit 1
    fi
done

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/main.c" "${SRC_DIR}/ft_putchar.c" \
    "${SRC_DIR}/ft_putnbr.c" "${SRC_DIR}/ft_putstr.c"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

# Run and capture output
RESULT=$(/tmp/${EXERCISE_ID}_test)

# Verify key lines
PASS=1
TESTS=0
PASSED=0

# Check first line (space, code 32)
FIRST_LINE=$(echo "$RESULT" | head -1)
if [ "$FIRST_LINE" == "32:  " ]; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: First line should be '32:  ' (space), got '$FIRST_LINE'"
    PASS=0
fi
TESTS=$((TESTS + 1))

# Check line for '!'
EXCL_LINE=$(echo "$RESULT" | grep "^33: ")
if [ "$EXCL_LINE" == "33: !" ]; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Line for code 33 should be '33: !', got '$EXCL_LINE'"
    PASS=0
fi
TESTS=$((TESTS + 1))

# Check line for 'A'
A_LINE=$(echo "$RESULT" | grep "^65: ")
if [ "$A_LINE" == "65: A" ]; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Line for code 65 should be '65: A', got '$A_LINE'"
    PASS=0
fi
TESTS=$((TESTS + 1))

# Check last line (tilde, code 126)
LAST_LINE=$(echo "$RESULT" | tail -1)
if [ "$LAST_LINE" == "126: ~" ]; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Last line should be '126: ~', got '$LAST_LINE'"
    PASS=0
fi
TESTS=$((TESTS + 1))

# Check total line count (95 printable characters: 32-126 inclusive)
LINE_COUNT=$(echo "$RESULT" | wc -l)
if [ "$LINE_COUNT" -eq 95 ]; then
    PASSED=$((PASSED + 1))
else
    echo "FAILED: Expected 95 lines, got $LINE_COUNT"
    PASS=0
fi
TESTS=$((TESTS + 1))

if [ "$PASS" -eq 1 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED (${PASSED}/${TESTS})"
    show_compile_count
    echo "Code: $HASH"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 0
else
    echo "FAILED (${PASSED}/${TESTS} passed)"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
