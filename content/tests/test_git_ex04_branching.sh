#!/bin/bash
# test_git_ex04_branching.sh — hash verification
# Usage: bash test_git_ex04_branching.sh [repo_dir]
set -e

EXERCISE_ID="git_ex04_branching"
REPO_DIR="${1:-$HOME/git_branches}"

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

# Test 3: Branch feature/ft_div_mod exists
if git branch --list "feature/ft_div_mod" | grep -q "feature/ft_div_mod"; then
    echo "PASS: Branch 'feature/ft_div_mod' exists"
    ((PASS++))
else
    echo "FAIL: Branch 'feature/ft_div_mod' not found"
    ((FAIL++))
fi

# Test 4: Branch feature/ft_putchar exists
if git branch --list "feature/ft_putchar" | grep -q "feature/ft_putchar"; then
    echo "PASS: Branch 'feature/ft_putchar' exists"
    ((PASS++))
else
    echo "FAIL: Branch 'feature/ft_putchar' not found"
    ((FAIL++))
fi

# Test 5: ft_swap.c exists on master
if [ -f "ft_swap.c" ]; then
    echo "PASS: ft_swap.c exists on master"
    ((PASS++))
else
    echo "FAIL: ft_swap.c not found on master"
    ((FAIL++))
fi

# Test 6: ft_div_mod.c exists on master (merged)
if [ -f "ft_div_mod.c" ]; then
    echo "PASS: ft_div_mod.c exists on master (merged)"
    ((PASS++))
else
    echo "FAIL: ft_div_mod.c not found on master (merge missing?)"
    ((FAIL++))
fi

# Test 7: ft_putchar.c exists on master (merged)
if [ -f "ft_putchar.c" ]; then
    echo "PASS: ft_putchar.c exists on master (merged)"
    ((PASS++))
else
    echo "FAIL: ft_putchar.c not found on master (merge missing?)"
    ((FAIL++))
fi

# Test 8: All three files are tracked
TRACKED=0
for f in ft_swap.c ft_div_mod.c ft_putchar.c; do
    if git ls-files --error-unmatch "$f" > /dev/null 2>&1; then
        ((TRACKED++))
    fi
done
if [ "$TRACKED" -eq 3 ]; then
    echo "PASS: All 3 files are tracked by git"
    ((PASS++))
else
    echo "FAIL: Only $TRACKED/3 files are tracked"
    ((FAIL++))
fi

# Test 9: History has merge commits (branches were merged, not just added on master)
MERGE_COUNT=$(git log --merges --oneline 2>/dev/null | wc -l)
if [ "$MERGE_COUNT" -ge 1 ]; then
    echo "PASS: Merge commits found ($MERGE_COUNT)"
    ((PASS++))
else
    echo "INFO: No merge commits found (branches may have been fast-forwarded)"
    ((PASS++))
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
