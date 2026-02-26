#!/bin/bash
# test_git_ex02_clone_push.sh — hash verification
# Usage: bash test_git_ex02_clone_push.sh [work_dir]
set -e

EXERCISE_ID="git_ex02_clone_push"
WORK_DIR="${1:-$HOME/c00_work}"
BARE_DIR="/tmp/vogsphere/c00.git"

echo "=== Testing: ${EXERCISE_ID} ==="

PASS=0
FAIL=0

# Test 1: Bare repository exists
if [ -d "$BARE_DIR" ] && [ -f "$BARE_DIR/HEAD" ]; then
    echo "PASS: Bare repository '$BARE_DIR' exists"
    ((PASS++))
else
    echo "FAIL: Bare repository '$BARE_DIR' not found"
    ((FAIL++))
fi

# Test 2: Working clone exists
if [ -d "$WORK_DIR/.git" ]; then
    echo "PASS: Working clone '$WORK_DIR' exists"
    ((PASS++))
else
    echo "FAIL: Working clone '$WORK_DIR' not found"
    ((FAIL++))
    echo "TESTS FAILED ($PASS passed, $FAIL failed)"
    exit 1
fi

cd "$WORK_DIR"

# Test 3: Remote 'origin' is configured
REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [ -n "$REMOTE" ]; then
    echo "PASS: Remote 'origin' is configured ($REMOTE)"
    ((PASS++))
else
    echo "FAIL: Remote 'origin' is not configured"
    ((FAIL++))
fi

# Test 4: ex00/ft_putchar.c exists and is tracked
if git ls-files --error-unmatch ex00/ft_putchar.c > /dev/null 2>&1; then
    echo "PASS: ex00/ft_putchar.c is tracked"
    ((PASS++))
else
    echo "FAIL: ex00/ft_putchar.c is not tracked"
    ((FAIL++))
fi

# Test 5: At least 1 commit
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
if [ "$COMMIT_COUNT" -ge 1 ]; then
    echo "PASS: At least 1 commit ($COMMIT_COUNT total)"
    ((PASS++))
else
    echo "FAIL: No commits found"
    ((FAIL++))
fi

# Test 6: Changes were pushed (verify by cloning bare again)
VERIFY_DIR="/tmp/${EXERCISE_ID}_verify_$$"
rm -rf "$VERIFY_DIR"
if git clone "$BARE_DIR" "$VERIFY_DIR" > /dev/null 2>&1; then
    if [ -f "$VERIFY_DIR/ex00/ft_putchar.c" ]; then
        echo "PASS: Push verified (file exists in fresh clone)"
        ((PASS++))
    else
        echo "FAIL: Push not verified (file missing in fresh clone)"
        ((FAIL++))
    fi
    rm -rf "$VERIFY_DIR"
else
    echo "FAIL: Could not clone bare repo for verification"
    ((FAIL++))
fi

# Test 7: ft_putchar.c contains write() not printf
if [ -f "ex00/ft_putchar.c" ]; then
    if grep -q 'write(' ex00/ft_putchar.c 2>/dev/null; then
        echo "PASS: ft_putchar.c uses write()"
        ((PASS++))
    else
        echo "FAIL: ft_putchar.c does not use write()"
        ((FAIL++))
    fi
    if grep -q 'printf\|scanf\|puts(' ex00/ft_putchar.c 2>/dev/null; then
        echo "FAIL: ft_putchar.c contains forbidden function (printf/scanf/puts)"
        ((FAIL++))
    else
        echo "PASS: No forbidden functions in ft_putchar.c"
        ((PASS++))
    fi
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
