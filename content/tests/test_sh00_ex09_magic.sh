#!/bin/bash
# test_sh00_ex09_magic.sh — hash verification
# Usage: bash test_sh00_ex09_magic.sh [source_dir]
set -e

EXERCISE_ID="sh00_ex09_magic"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check that magic_file exists
if [ ! -f "${SRC_DIR}/magic_file" ]; then
    echo "FAILED: File 'magic_file' not found in ${SRC_DIR}/"
    exit 1
fi

# Check that file is not empty
FILE_SIZE=$(wc -c < "${SRC_DIR}/magic_file")
if [ "$FILE_SIZE" -lt 5 ]; then
    echo "FAILED: magic_file seems too small (${FILE_SIZE} bytes)"
    exit 1
fi
echo "  File size: OK (${FILE_SIZE} bytes)"

# Check that file command is available
if ! command -v file &> /dev/null; then
    echo "FAILED: 'file' command not found. Install with: sudo apt install file"
    exit 1
fi

# Create test files
TMPDIR=$(mktemp -d)

# File that starts with "42"
echo "42 is the answer to everything" > "${TMPDIR}/test_42"

# File that does NOT start with "42"
echo "Hello world" > "${TMPDIR}/test_other"

# Empty file
touch "${TMPDIR}/test_empty"

PASS=true

# Test 1: File starting with "42" should be identified as "42 file"
RESULT=$(file -m "${SRC_DIR}/magic_file" "${TMPDIR}/test_42" 2>&1)
if echo "$RESULT" | grep -qi "42 file"; then
    echo "  Detects '42' file: OK"
else
    echo "FAILED: File starting with '42' should be detected as '42 file'"
    echo "  Got: ${RESULT}"
    PASS=false
fi

# Test 2: File NOT starting with "42" should NOT be "42 file"
RESULT=$(file -m "${SRC_DIR}/magic_file" "${TMPDIR}/test_other" 2>&1)
if echo "$RESULT" | grep -qi "42 file"; then
    echo "FAILED: File NOT starting with '42' should NOT be detected as '42 file'"
    echo "  Got: ${RESULT}"
    PASS=false
else
    echo "  Non-42 file: OK (not matched)"
fi

rm -rf "$TMPDIR"

# Result
if [ "$PASS" = true ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    echo "Code: $HASH"
    exit 0
else
    echo "TESTS FAILED"
    exit 1
fi
