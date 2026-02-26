#!/bin/bash
# test_git_ex06_gitignore.sh — hash verification
# Usage: bash test_git_ex06_gitignore.sh [repo_dir]
set -e

EXERCISE_ID="git_ex06_gitignore"
REPO_DIR="${1:-$HOME/git_ignore_practice}"

echo "=== Testing: ${EXERCISE_ID} ==="

PASS=0
FAIL=0

# Test 1: Directory exists and is a git repo
if [ -d "$REPO_DIR/.git" ]; then
    echo "PASS: '$REPO_DIR' is a git repository"
    ((PASS++))
else
    echo "FAIL: '$REPO_DIR' is not a git repository"
    ((FAIL++))
    echo "TESTS FAILED ($PASS passed, $FAIL failed)"
    exit 1
fi

cd "$REPO_DIR"

# Test 2: .gitignore exists and is tracked
if git ls-files --error-unmatch .gitignore > /dev/null 2>&1; then
    echo "PASS: .gitignore is tracked"
    ((PASS++))
else
    echo "FAIL: .gitignore is not tracked"
    ((FAIL++))
fi

# Test 3: .c files are tracked
TRACKED_C=0
for f in ft_putchar.c main.c; do
    if git ls-files --error-unmatch "$f" > /dev/null 2>&1; then
        ((TRACKED_C++))
    fi
done
if [ "$TRACKED_C" -eq 2 ]; then
    echo "PASS: Source .c files are tracked"
    ((PASS++))
else
    echo "FAIL: Not all .c files are tracked ($TRACKED_C/2)"
    ((FAIL++))
fi

# Test 4: .o files are NOT tracked
TRACKED_O=0
for f in $(find . -name "*.o" 2>/dev/null); do
    if git ls-files --error-unmatch "$f" > /dev/null 2>&1; then
        ((TRACKED_O++))
    fi
done
if [ "$TRACKED_O" -eq 0 ]; then
    echo "PASS: No .o files are tracked"
    ((PASS++))
else
    echo "FAIL: $TRACKED_O .o files are tracked (should be ignored)"
    ((FAIL++))
fi

# Test 5: .gitignore contains *.o pattern
if grep -q '^\*\.o' .gitignore 2>/dev/null; then
    echo "PASS: .gitignore contains *.o pattern"
    ((PASS++))
else
    echo "FAIL: .gitignore missing *.o pattern"
    ((FAIL++))
fi

# Test 6: .gitignore contains a.out
if grep -q 'a\.out' .gitignore 2>/dev/null; then
    echo "PASS: .gitignore contains a.out pattern"
    ((PASS++))
else
    echo "FAIL: .gitignore missing a.out pattern"
    ((FAIL++))
fi

# Test 7: .gitignore contains *.a
if grep -q '^\*\.a' .gitignore 2>/dev/null; then
    echo "PASS: .gitignore contains *.a pattern"
    ((PASS++))
else
    echo "FAIL: .gitignore missing *.a pattern"
    ((FAIL++))
fi

# Test 8: .gitignore contains *~ (backup files)
if grep -q '^\*~' .gitignore 2>/dev/null; then
    echo "PASS: .gitignore contains *~ pattern"
    ((PASS++))
else
    echo "FAIL: .gitignore missing *~ pattern"
    ((FAIL++))
fi

# Test 9: .gitignore contains .DS_Store
if grep -q '\.DS_Store' .gitignore 2>/dev/null; then
    echo "PASS: .gitignore contains .DS_Store pattern"
    ((PASS++))
else
    echo "FAIL: .gitignore missing .DS_Store pattern"
    ((FAIL++))
fi

# Test 10: .gitignore contains *.swp
if grep -q '^\*\.swp' .gitignore 2>/dev/null; then
    echo "PASS: .gitignore contains *.swp pattern"
    ((PASS++))
else
    echo "FAIL: .gitignore missing *.swp pattern"
    ((FAIL++))
fi

# Test 11: git check-ignore verifies .o files are ignored
if echo "test.o" | git check-ignore --stdin > /dev/null 2>&1; then
    echo "PASS: .o files are actually ignored by git"
    ((PASS++))
else
    echo "FAIL: .o files are not ignored by git (check .gitignore)"
    ((FAIL++))
fi

# Test 12: Working tree is clean
STATUS=$(git status --porcelain 2>/dev/null)
if [ -z "$STATUS" ]; then
    echo "PASS: Working tree is clean"
    ((PASS++))
else
    echo "FAIL: Working tree is not clean"
    echo "  Untracked/modified: $STATUS"
    ((FAIL++))
fi

# Result
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -eq 0 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    echo "Code: $HASH"
    exit 0
else
    echo "TESTS FAILED"
    exit 1
fi
