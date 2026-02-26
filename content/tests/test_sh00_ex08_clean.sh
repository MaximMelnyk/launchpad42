#!/bin/bash
# test_sh00_ex08_clean.sh — hash verification
# Usage: bash test_sh00_ex08_clean.sh [source_dir]
set -e

EXERCISE_ID="sh00_ex08_clean"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check that clean file exists
if [ ! -f "${SRC_DIR}/clean" ]; then
    echo "FAILED: File 'clean' not found in ${SRC_DIR}/"
    exit 1
fi

# Check that file is not empty
FILE_SIZE=$(wc -c < "${SRC_DIR}/clean")
if [ "$FILE_SIZE" -lt 5 ]; then
    echo "FAILED: clean seems too small (${FILE_SIZE} bytes)"
    exit 1
fi

# Check that command uses find
if ! grep -q 'find' "${SRC_DIR}/clean"; then
    echo "FAILED: clean must use the 'find' command"
    exit 1
fi
echo "  Uses find: OK"

# Create test directory structure
TMPDIR=$(mktemp -d)
mkdir -p "${TMPDIR}/testarea/subdir1/subdir2"

# Files that SHOULD be deleted
touch "${TMPDIR}/testarea/backup~"
touch "${TMPDIR}/testarea/old_file~"
touch "${TMPDIR}/testarea/subdir1/deep~"
touch "${TMPDIR}/testarea/#autosave#"
touch "${TMPDIR}/testarea/subdir1/#emacs_save#"
touch "${TMPDIR}/testarea/main.o"
touch "${TMPDIR}/testarea/subdir1/utils.o"
touch "${TMPDIR}/testarea/subdir1/subdir2/deep.o"

# Files that should NOT be deleted
touch "${TMPDIR}/testarea/main.c"
touch "${TMPDIR}/testarea/header.h"
touch "${TMPDIR}/testarea/Makefile"
touch "${TMPDIR}/testarea/subdir1/utils.c"

# Run clean from the test directory
cd "${TMPDIR}/testarea"
bash "${SRC_DIR}/clean"

PASS=true

# Check that junk files are gone
SHOULD_BE_GONE="backup~ old_file~ subdir1/deep~ #autosave# subdir1/#emacs_save# main.o subdir1/utils.o subdir1/subdir2/deep.o"
for f in $SHOULD_BE_GONE; do
    if [ -f "${TMPDIR}/testarea/${f}" ]; then
        echo "FAILED: '${f}' should have been deleted but still exists"
        PASS=false
    else
        echo "  Deleted '${f}': OK"
    fi
done

# Check that source files are intact
SHOULD_REMAIN="main.c header.h Makefile subdir1/utils.c"
for f in $SHOULD_REMAIN; do
    if [ ! -f "${TMPDIR}/testarea/${f}" ]; then
        echo "FAILED: '${f}' should NOT have been deleted but is missing"
        PASS=false
    else
        echo "  Kept '${f}': OK"
    fi
done

cd /tmp
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
