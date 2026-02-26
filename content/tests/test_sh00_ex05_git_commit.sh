#!/bin/bash
# test_sh00_ex05_git_commit.sh — hash verification
# Usage: bash test_sh00_ex05_git_commit.sh [source_dir]
set -e

EXERCISE_ID="sh00_ex05_git_commit"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check that script exists
if [ ! -f "${SRC_DIR}/git_commit.sh" ]; then
    echo "FAILED: File 'git_commit.sh' not found in ${SRC_DIR}/"
    exit 1
fi

# Create a temporary git repo for testing
TMPDIR=$(mktemp -d)
cd "$TMPDIR"
git init -q
git config user.email "test@test.com"
git config user.name "Test"

# Create 7 commits (test expects last 5)
for i in 1 2 3 4 5 6 7; do
    echo "commit $i" > "file${i}.txt"
    git add "file${i}.txt"
    git commit -q -m "Commit number $i"
done

# Get expected output: last 5 commit hashes, first 8 chars
EXPECTED=$(git log --format='%H' -5 | cut -c1-8)

# Copy and run the student script
cp "${SRC_DIR}/git_commit.sh" "$TMPDIR/"
RESULT=$(bash git_commit.sh 2>&1)

cd /tmp
rm -rf "$TMPDIR"

# Compare results
if [ "$RESULT" = "$EXPECTED" ]; then
    echo "  Output matches expected hashes"
else
    echo "FAILED: Output does not match expected"
    echo "  Expected:"
    echo "$EXPECTED" | while read line; do echo "    $line"; done
    echo "  Got:"
    echo "$RESULT" | while read line; do echo "    $line"; done
    exit 1
fi

# Check output format: each line should be exactly 8 hex characters
LINE_COUNT=$(echo "$RESULT" | wc -l)
if [ "$LINE_COUNT" -ne 5 ]; then
    echo "FAILED: Expected 5 lines, got ${LINE_COUNT}"
    exit 1
fi
echo "  Line count: OK (5)"

BAD_FORMAT=false
while IFS= read -r line; do
    if ! echo "$line" | grep -qE '^[0-9a-f]{8}$'; then
        echo "FAILED: Line '${line}' is not 8 hex characters"
        BAD_FORMAT=true
    fi
done <<< "$RESULT"

if [ "$BAD_FORMAT" = true ]; then
    exit 1
fi
echo "  Format: OK (all lines are 8 hex chars)"

# All tests passed
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
