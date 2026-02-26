#!/bin/bash
# test_sh00_ex02_oh_yeah.sh — hash verification
# Usage: bash test_sh00_ex02_oh_yeah.sh [source_dir]
set -e

EXERCISE_ID="sh00_ex02_oh_yeah"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check that tar archive exists
if [ ! -f "${SRC_DIR}/exo2.tar" ]; then
    echo "FAILED: File 'exo2.tar' not found in ${SRC_DIR}/"
    exit 1
fi

# Extract to temp directory
TMPDIR=$(mktemp -d)
tar -xf "${SRC_DIR}/exo2.tar" -C "$TMPDIR"

PASS=true

# --- testShell00 ---
FILE="${TMPDIR}/testShell00"
if [ ! -f "$FILE" ]; then
    echo "FAILED: testShell00 not found in archive"
    PASS=false
else
    PERMS=$(stat -c "%a" "$FILE")
    SIZE=$(stat -c "%s" "$FILE")
    DATE=$(stat -c "%y" "$FILE" | cut -c1-16)
    if [ "$PERMS" != "455" ]; then
        echo "FAILED: testShell00 permissions must be 455, got ${PERMS}"
        PASS=false
    fi
    if [ "$SIZE" -ne 40 ]; then
        echo "FAILED: testShell00 size must be 40, got ${SIZE}"
        PASS=false
    fi
    if [ "$DATE" != "2025-06-01 23:42" ]; then
        echo "FAILED: testShell00 date must be '2025-06-01 23:42', got '${DATE}'"
        PASS=false
    fi
    if [ "$PASS" = true ]; then
        echo "  testShell00: OK (perms=${PERMS}, size=${SIZE}, date=${DATE})"
    fi
fi

# --- testShell01 ---
FILE="${TMPDIR}/testShell01"
if [ ! -f "$FILE" ]; then
    echo "FAILED: testShell01 not found in archive"
    PASS=false
else
    PERMS=$(stat -c "%a" "$FILE")
    SIZE=$(stat -c "%s" "$FILE")
    DATE=$(stat -c "%y" "$FILE" | cut -c1-16)
    if [ "$PERMS" != "714" ]; then
        echo "FAILED: testShell01 permissions must be 714, got ${PERMS}"
        PASS=false
    fi
    if [ "$SIZE" -ne 20 ]; then
        echo "FAILED: testShell01 size must be 20, got ${SIZE}"
        PASS=false
    fi
    if [ "$DATE" != "2025-06-01 23:42" ]; then
        echo "FAILED: testShell01 date must be '2025-06-01 23:42', got '${DATE}'"
        PASS=false
    fi
    if [ "$PASS" = true ]; then
        echo "  testShell01: OK (perms=${PERMS}, size=${SIZE}, date=${DATE})"
    fi
fi

# --- testShell02 ---
FILE="${TMPDIR}/testShell02"
if [ ! -f "$FILE" ]; then
    echo "FAILED: testShell02 not found in archive"
    PASS=false
else
    PERMS=$(stat -c "%a" "$FILE")
    SIZE=$(stat -c "%s" "$FILE")
    DATE=$(stat -c "%y" "$FILE" | cut -c1-16)
    if [ "$PERMS" != "710" ]; then
        echo "FAILED: testShell02 permissions must be 710, got ${PERMS}"
        PASS=false
    fi
    if [ "$SIZE" -ne 100 ]; then
        echo "FAILED: testShell02 size must be 100, got ${SIZE}"
        PASS=false
    fi
    if [ "$DATE" != "2025-06-01 23:42" ]; then
        echo "FAILED: testShell02 date must be '2025-06-01 23:42', got '${DATE}'"
        PASS=false
    fi
    if [ "$PASS" = true ]; then
        echo "  testShell02: OK (perms=${PERMS}, size=${SIZE}, date=${DATE})"
    fi
fi

# Cleanup
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
