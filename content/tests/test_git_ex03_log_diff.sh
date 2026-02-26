#!/bin/bash
# test_git_ex03_log_diff.sh — hash verification
# Usage: bash test_git_ex03_log_diff.sh [repo_dir]
set -e

EXERCISE_ID="git_ex03_log_diff"
REPO_DIR="${1:-$HOME/git_log_practice}"

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

# Test 2: Exactly 3 commits
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
if [ "$COMMIT_COUNT" -eq 3 ]; then
    echo "PASS: Exactly 3 commits in history"
    ((PASS++))
else
    echo "FAIL: Expected 3 commits, got $COMMIT_COUNT"
    ((FAIL++))
fi

# Test 3: Check commit messages (oldest to newest)
FIRST_MSG=$(git log --format="%s" --reverse | head -1)
SECOND_MSG=$(git log --format="%s" --reverse | head -2 | tail -1)
THIRD_MSG=$(git log --format="%s" --reverse | tail -1)

if [ "$FIRST_MSG" == "Add ft_strlen" ]; then
    echo "PASS: First commit message is 'Add ft_strlen'"
    ((PASS++))
else
    echo "FAIL: Expected first commit 'Add ft_strlen', got '$FIRST_MSG'"
    ((FAIL++))
fi

if [ "$SECOND_MSG" == "Make ft_strlen parameter const" ]; then
    echo "PASS: Second commit message is 'Make ft_strlen parameter const'"
    ((PASS++))
else
    echo "FAIL: Expected second commit 'Make ft_strlen parameter const', got '$SECOND_MSG'"
    ((FAIL++))
fi

if [ "$THIRD_MSG" == "Add ft_putstr" ]; then
    echo "PASS: Third commit message is 'Add ft_putstr'"
    ((PASS++))
else
    echo "FAIL: Expected third commit 'Add ft_putstr', got '$THIRD_MSG'"
    ((FAIL++))
fi

# Test 4: ft_strlen.c exists and is tracked
if git ls-files --error-unmatch ft_strlen.c > /dev/null 2>&1; then
    echo "PASS: ft_strlen.c is tracked"
    ((PASS++))
else
    echo "FAIL: ft_strlen.c is not tracked"
    ((FAIL++))
fi

# Test 5: ft_putstr.c exists and is tracked
if git ls-files --error-unmatch ft_putstr.c > /dev/null 2>&1; then
    echo "PASS: ft_putstr.c is tracked"
    ((PASS++))
else
    echo "FAIL: ft_putstr.c is not tracked"
    ((FAIL++))
fi

# Test 6: ft_strlen.c has 'const' parameter (latest version)
if grep -q 'const char \*str' ft_strlen.c 2>/dev/null; then
    echo "PASS: ft_strlen.c has const parameter"
    ((PASS++))
else
    echo "FAIL: ft_strlen.c missing const parameter"
    ((FAIL++))
fi

# Test 7: git_log_report.txt exists and has 3 lines
if [ -f "git_log_report.txt" ]; then
    LINE_COUNT=$(wc -l < git_log_report.txt)
    if [ "$LINE_COUNT" -eq 3 ]; then
        echo "PASS: git_log_report.txt has 3 lines"
        ((PASS++))
    else
        echo "FAIL: git_log_report.txt has $LINE_COUNT lines, expected 3"
        ((FAIL++))
    fi
else
    echo "FAIL: git_log_report.txt not found"
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
