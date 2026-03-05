#!/bin/bash
# test_p0_d01_hello_world.sh — hash verification
# Usage: bash test_p0_d01_hello_world.sh [source_dir]
set -e

EXERCISE_ID="p0_d01_hello_world"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"
SRC_FILE="${SRC_DIR}/hello.c"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source file exists
if [ ! -f "$SRC_FILE" ]; then
    echo "FAILED: File '${SRC_FILE}' not found"
    exit 1
fi

# Check for forbidden functions
if grep -q 'printf\|scanf\|puts(' "$SRC_FILE" 2>/dev/null; then
    echo "FAILED: Forbidden function detected (printf/scanf/puts)"
    exit 1
fi

# Compile
echo "Compiling..."
gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test "$SRC_FILE"
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    exit 1
fi

# Run and capture output
RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="Hello, 42!"

if [ "$RESULT" == "$EXPECTED" ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    show_compile_count
    echo "Code: $HASH"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 0
else
    echo "FAILED"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$RESULT'"
    rm -f /tmp/${EXERCISE_ID}_test
    exit 1
fi
