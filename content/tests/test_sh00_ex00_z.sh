#!/bin/bash
# test_sh00_ex00_z.sh — hash verification
# Usage: bash test_sh00_ex00_z.sh [source_dir]
set -e

EXERCISE_ID="sh00_ex00_z"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check that file Z exists
if [ ! -f "${SRC_DIR}/Z" ]; then
    echo "FAILED: File 'Z' not found in ${SRC_DIR}/"
    exit 1
fi

# Check file size (must be exactly 2 bytes: 'Z' + '\n')
FILE_SIZE=$(wc -c < "${SRC_DIR}/Z")
if [ "$FILE_SIZE" -ne 2 ]; then
    echo "FAILED: File 'Z' must be exactly 2 bytes, got ${FILE_SIZE}"
    exit 1
fi

# Check content with cat
RESULT=$(cat "${SRC_DIR}/Z")
EXPECTED="Z"

if [ "$RESULT" != "$EXPECTED" ]; then
    echo "FAILED: cat Z should output 'Z', got '${RESULT}'"
    exit 1
fi

# Check that file ends with newline
LAST_BYTE=$(xxd -p -l 1 -s 1 "${SRC_DIR}/Z")
if [ "$LAST_BYTE" != "0a" ]; then
    echo "FAILED: File must end with newline (\\n)"
    exit 1
fi

# All tests passed
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
