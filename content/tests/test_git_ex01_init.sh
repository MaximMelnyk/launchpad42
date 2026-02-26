#!/bin/bash
# test_git_ex01_init.sh — hash verification
# Usage: bash test_git_ex01_init.sh [repo_dir]
set -e

EXERCISE_ID="git_ex01_init"
REPO_DIR="${1:-$HOME/my_first_repo}"

echo "=== Testing: ${EXERCISE_ID} ==="

PASS=0
FAIL=0

# Test 1: Directory exists
if [ -d "$REPO_DIR" ]; then
    echo "PASS: Directory '$REPO_DIR' exists"
    ((PASS++))
else
    echo "FAIL: Directory '$REPO_DIR' not found"
    ((FAIL++))
    echo "TESTS FAILED ($PASS passed, $FAIL failed)"
    exit 1
fi

# Test 2: Is a git repository
if [ -d "$REPO_DIR/.git" ]; then
    echo "PASS: Is a git repository (.git/ exists)"
    ((PASS++))
else
    echo "FAIL: Not a git repository (.git/ not found)"
    ((FAIL++))
    echo "TESTS FAILED ($PASS passed, $FAIL failed)"
    exit 1
fi

cd "$REPO_DIR"

# Test 3: hello.c exists and is tracked
if git ls-files --error-unmatch hello.c > /dev/null 2>&1; then
    echo "PASS: hello.c is tracked by git"
    ((PASS++))
else
    echo "FAIL: hello.c is not tracked by git"
    ((FAIL++))
fi

# Test 4: Exactly 1 commit
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
if [ "$COMMIT_COUNT" -eq 1 ]; then
    echo "PASS: Exactly 1 commit in history"
    ((PASS++))
else
    echo "FAIL: Expected 1 commit, got $COMMIT_COUNT"
    ((FAIL++))
fi

# Test 5: Commit message is "Initial commit"
COMMIT_MSG=$(git log --format="%s" -1 2>/dev/null || echo "")
if [ "$COMMIT_MSG" == "Initial commit" ]; then
    echo "PASS: Commit message is 'Initial commit'"
    ((PASS++))
else
    echo "FAIL: Expected commit message 'Initial commit', got '$COMMIT_MSG'"
    ((FAIL++))
fi

# Test 6: Working tree is clean
STATUS=$(git status --porcelain 2>/dev/null)
if [ -z "$STATUS" ]; then
    echo "PASS: Working tree is clean"
    ((PASS++))
else
    echo "FAIL: Working tree is not clean"
    ((FAIL++))
fi

# Test 7: hello.c compiles
if gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test hello.c 2>/dev/null; then
    echo "PASS: hello.c compiles with -Wall -Wextra -Werror"
    ((PASS++))
    RESULT=$(/tmp/${EXERCISE_ID}_test)
    if [ "$RESULT" == "Hi" ]; then
        echo "PASS: Output is correct ('Hi')"
        ((PASS++))
    else
        echo "FAIL: Expected output 'Hi', got '$RESULT'"
        ((FAIL++))
    fi
    rm -f /tmp/${EXERCISE_ID}_test
else
    echo "FAIL: hello.c does not compile"
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
