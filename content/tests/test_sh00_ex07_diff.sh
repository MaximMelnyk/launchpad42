#!/bin/bash
# test_sh00_ex07_diff.sh — hash verification
# Usage: bash test_sh00_ex07_diff.sh [source_dir]
set -e

EXERCISE_ID="sh00_ex07_diff"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check that sw.diff exists
if [ ! -f "${SRC_DIR}/sw.diff" ]; then
    echo "FAILED: File 'sw.diff' not found in ${SRC_DIR}/"
    exit 1
fi

# Check that file is not empty
FILE_SIZE=$(wc -c < "${SRC_DIR}/sw.diff")
if [ "$FILE_SIZE" -lt 10 ]; then
    echo "FAILED: sw.diff seems too small (${FILE_SIZE} bytes)"
    exit 1
fi
echo "  File size: OK (${FILE_SIZE} bytes)"

# Check that it looks like unified diff format
if ! head -3 "${SRC_DIR}/sw.diff" | grep -q '^---'; then
    echo "FAILED: sw.diff does not appear to be in unified diff format (missing '---' header)"
    exit 1
fi
if ! head -3 "${SRC_DIR}/sw.diff" | grep -q '^+++'; then
    echo "FAILED: sw.diff does not appear to be in unified diff format (missing '+++' header)"
    exit 1
fi
echo "  Format: OK (unified diff)"

# Create the original file (file1)
TMPDIR=$(mktemp -d)
cat > "${TMPDIR}/file1" << 'EOF'
This is the original file.
It has some content.
Line three here.
EOF

# Expected result after patch (file2)
cat > "${TMPDIR}/file2_expected" << 'EOF'
This is the modified file.
It has some content.
Line three has been changed.
And a new line was added.
EOF

# Apply the patch
cp "${TMPDIR}/file1" "${TMPDIR}/file1_patched"
if ! patch "${TMPDIR}/file1_patched" "${SRC_DIR}/sw.diff" > /dev/null 2>&1; then
    echo "FAILED: Could not apply sw.diff to file1"
    rm -rf "$TMPDIR"
    exit 1
fi
echo "  Patch applies: OK"

# Compare result with expected
if diff -q "${TMPDIR}/file1_patched" "${TMPDIR}/file2_expected" > /dev/null 2>&1; then
    echo "  Patched content: OK (matches expected file2)"
else
    echo "FAILED: After applying patch, file1 does not match expected file2"
    echo "  Expected:"
    cat "${TMPDIR}/file2_expected" | while read line; do echo "    $line"; done
    echo "  Got:"
    cat "${TMPDIR}/file1_patched" | while read line; do echo "    $line"; done
    rm -rf "$TMPDIR"
    exit 1
fi

rm -rf "$TMPDIR"

# All tests passed
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
