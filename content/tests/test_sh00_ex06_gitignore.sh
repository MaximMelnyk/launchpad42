#!/bin/bash
# test_sh00_ex06_gitignore.sh — hash verification
# Usage: bash test_sh00_ex06_gitignore.sh [source_dir]
set -e

EXERCISE_ID="sh00_ex06_gitignore"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check that .gitignore exists
if [ ! -f "${SRC_DIR}/.gitignore" ]; then
    echo "FAILED: File '.gitignore' not found in ${SRC_DIR}/"
    exit 1
fi

# Check that .gitignore is not empty
FILE_SIZE=$(wc -c < "${SRC_DIR}/.gitignore")
if [ "$FILE_SIZE" -lt 5 ]; then
    echo "FAILED: .gitignore seems too small (${FILE_SIZE} bytes)"
    exit 1
fi

# Create a temp git repo to test ignore patterns
TMPDIR=$(mktemp -d)
cd "$TMPDIR"
git init -q
git config user.email "test@test.com"
git config user.name "Test"
cp "${SRC_DIR}/.gitignore" .

# Create test files: some should be ignored, some should not
touch file.c file.h Makefile          # Should NOT be ignored
touch file.o libft.a                  # Should be ignored (*.o, *.a)
touch "backup~" "file.c~"            # Should be ignored (*~)
touch test.swp                        # Should be ignored (*.swp)
touch a.out                           # Should be ignored

# Check each pattern
PASS=true

# Files that SHOULD be ignored
SHOULD_IGNORE="file.o libft.a backup~ file.c~ test.swp a.out"
for f in $SHOULD_IGNORE; do
    if git check-ignore -q "$f" 2>/dev/null; then
        echo "  Ignores '${f}': OK"
    else
        echo "FAILED: '${f}' should be ignored but is not"
        PASS=false
    fi
done

# Files that should NOT be ignored
SHOULD_KEEP="file.c file.h Makefile"
for f in $SHOULD_KEEP; do
    if git check-ignore -q "$f" 2>/dev/null; then
        echo "FAILED: '${f}' should NOT be ignored but is"
        PASS=false
    else
        echo "  Keeps '${f}': OK"
    fi
done

cd /tmp
rm -rf "$TMPDIR"

# Result
if [ "$PASS" = true ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    show_compile_count
    echo "Code: $HASH"
    exit 0
else
    echo "TESTS FAILED"
    exit 1
fi
