#!/bin/bash
# test_git_ex05_conflicts.sh — hash verification
# Usage: bash test_git_ex05_conflicts.sh [repo_dir]
set -e

EXERCISE_ID="git_ex05_conflicts"
REPO_DIR="${1:-$HOME/git_conflict}"

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

# Test 2: Currently on master (or main)
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [ "$CURRENT_BRANCH" == "master" ] || [ "$CURRENT_BRANCH" == "main" ]; then
    echo "PASS: Currently on branch '$CURRENT_BRANCH'"
    ((PASS++))
else
    echo "FAIL: Expected to be on master/main, got '$CURRENT_BRANCH'"
    ((FAIL++))
fi

# Test 3: Branch 'refactor' exists
if git branch --list "refactor" | grep -q "refactor"; then
    echo "PASS: Branch 'refactor' exists"
    ((PASS++))
else
    echo "FAIL: Branch 'refactor' not found"
    ((FAIL++))
fi

# Test 4: ft_abs.c exists
if [ -f "ft_abs.c" ]; then
    echo "PASS: ft_abs.c exists"
    ((PASS++))
else
    echo "FAIL: ft_abs.c not found"
    ((FAIL++))
    echo "TESTS FAILED ($PASS passed, $FAIL failed)"
    exit 1
fi

# Test 5: No conflict markers in ft_abs.c
if grep -qE '<<<<<<<|=======|>>>>>>>' ft_abs.c 2>/dev/null; then
    echo "FAIL: ft_abs.c still contains conflict markers!"
    ((FAIL++))
else
    echo "PASS: No conflict markers in ft_abs.c"
    ((PASS++))
fi

# Test 6: ft_abs.c compiles
if gcc -Wall -Wextra -Werror -c ft_abs.c -o /tmp/${EXERCISE_ID}_test.o 2>/dev/null; then
    echo "PASS: ft_abs.c compiles with -Wall -Wextra -Werror"
    ((PASS++))
    rm -f /tmp/${EXERCISE_ID}_test.o
else
    echo "FAIL: ft_abs.c does not compile"
    ((FAIL++))
fi

# Test 7: ft_abs.c contains a function ft_abs
if grep -q 'ft_abs' ft_abs.c 2>/dev/null; then
    echo "PASS: ft_abs function found in ft_abs.c"
    ((PASS++))
else
    echo "FAIL: ft_abs function not found in ft_abs.c"
    ((FAIL++))
fi

# Test 8: Merge commit exists (conflict was resolved via merge)
MERGE_COUNT=$(git log --merges --oneline 2>/dev/null | wc -l)
if [ "$MERGE_COUNT" -ge 1 ]; then
    echo "PASS: Merge commit found (conflict was resolved)"
    ((PASS++))
else
    echo "FAIL: No merge commit found (was the conflict resolved via merge?)"
    ((FAIL++))
fi

# Test 9: At least 4 commits (initial + refactor branch + master change + merge)
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
if [ "$COMMIT_COUNT" -ge 4 ]; then
    echo "PASS: At least 4 commits ($COMMIT_COUNT total)"
    ((PASS++))
else
    echo "FAIL: Expected at least 4 commits, got $COMMIT_COUNT"
    ((FAIL++))
fi

# Test 10: Working tree is clean (no uncommitted merge artifacts)
STATUS=$(git status --porcelain 2>/dev/null)
if [ -z "$STATUS" ]; then
    echo "PASS: Working tree is clean"
    ((PASS++))
else
    echo "FAIL: Working tree is not clean"
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
