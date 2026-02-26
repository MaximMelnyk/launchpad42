#!/bin/bash
# test_sh00_ex04_midls.sh — hash verification
# Usage: bash test_sh00_ex04_midls.sh [source_dir]
set -e

EXERCISE_ID="sh00_ex04_midls"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check that midLS file exists
if [ ! -f "${SRC_DIR}/midLS" ]; then
    echo "FAILED: File 'midLS' not found in ${SRC_DIR}/"
    exit 1
fi

# Check that file is not empty
FILE_SIZE=$(wc -c < "${SRC_DIR}/midLS")
if [ "$FILE_SIZE" -lt 3 ]; then
    echo "FAILED: midLS seems too small (${FILE_SIZE} bytes)"
    exit 1
fi

# Read the command from the file
CMD=$(head -1 "${SRC_DIR}/midLS" | tr -d '\n')

# If file has shebang, read the second line
if echo "$CMD" | grep -q '^#!'; then
    CMD=$(sed -n '2p' "${SRC_DIR}/midLS" | tr -d '\n')
fi

echo "  Command: '${CMD}'"

# Check that command starts with ls
if ! echo "$CMD" | grep -qE '^\s*ls\b'; then
    echo "FAILED: Command must start with 'ls'"
    exit 1
fi

# Check for required options: -l, -m, -p, -t (in any order/grouping)
MISSING=""
for opt in l m p t; do
    if ! echo "$CMD" | grep -qE "(-[a-zA-Z]*${opt}|--)" ; then
        MISSING="${MISSING} -${opt}"
    fi
done

if [ -n "$MISSING" ]; then
    echo "FAILED: Missing options:${MISSING}"
    echo "  Command must include -l, -m, -p, -t (can be combined: ls -lmpt)"
    exit 1
fi
echo "  Options: OK (all required options found)"

# Check that file ends with newline
LAST_CHAR=$(tail -c 1 "${SRC_DIR}/midLS" | xxd -p)
if [ "$LAST_CHAR" != "0a" ]; then
    echo "FAILED: File must end with newline"
    exit 1
fi
echo "  Newline: OK"

# Test execution in a temp directory
TMPDIR=$(mktemp -d)
mkdir -p "${TMPDIR}/testdir"
touch "${TMPDIR}/testdir/file_a.txt"
mkdir "${TMPDIR}/testdir/subdir"

RESULT=$(cd "${TMPDIR}/testdir" && bash "${SRC_DIR}/midLS" 2>&1) || true

# Check that output contains expected format elements
if echo "$RESULT" | grep -q "total"; then
    echo "  Execution: OK (ls output contains 'total' header)"
else
    echo "WARNING: Command executed but output format may be unexpected"
fi

rm -rf "$TMPDIR"

# All tests passed
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
