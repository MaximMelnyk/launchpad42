#!/bin/bash
# test_sh00_ex01_testshell00.sh — hash verification
# Usage: bash test_sh00_ex01_testshell00.sh [source_dir]
set -e

EXERCISE_ID="sh00_ex01_testshell00"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check that file exists
if [ ! -f "${SRC_DIR}/testShell00" ]; then
    echo "FAILED: File 'testShell00' not found in ${SRC_DIR}/"
    exit 1
fi

# Check permissions (must be 0455 = -r--r-xr-x)
PERMS=$(stat -c "%a" "${SRC_DIR}/testShell00")
if [ "$PERMS" != "455" ]; then
    echo "FAILED: Permissions must be 455 (-r--r-xr-x), got ${PERMS}"
    exit 1
fi
echo "  Permissions: OK (${PERMS})"

# Check file size (must be exactly 40 bytes)
FILE_SIZE=$(stat -c "%s" "${SRC_DIR}/testShell00")
if [ "$FILE_SIZE" -ne 40 ]; then
    echo "FAILED: File size must be 40 bytes, got ${FILE_SIZE}"
    exit 1
fi
echo "  Size: OK (${FILE_SIZE} bytes)"

# Check modification date (2025-06-01 23:42)
MOD_DATE=$(stat -c "%y" "${SRC_DIR}/testShell00" | cut -c1-16)
EXPECTED_DATE="2025-06-01 23:42"
if [ "$MOD_DATE" != "$EXPECTED_DATE" ]; then
    echo "FAILED: Modification date must be '${EXPECTED_DATE}', got '${MOD_DATE}'"
    exit 1
fi
echo "  Date: OK (${MOD_DATE})"

# All tests passed
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
