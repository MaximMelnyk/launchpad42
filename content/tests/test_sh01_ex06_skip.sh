#!/bin/bash
# test_sh01_ex06_skip.sh — hash verification
# Usage: bash test_sh01_ex06_skip.sh [source_dir]
set -e

EXERCISE_ID="sh01_ex06_skip"
SRC_DIR="${1:-.}"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source file exists
if [ ! -f "${SRC_DIR}/skip.sh" ]; then
    echo "FAILED: File 'skip.sh' not found"
    exit 1
fi

# Check shebang
FIRST_LINE=$(head -1 "${SRC_DIR}/skip.sh")
if [ "$FIRST_LINE" != "#!/bin/sh" ]; then
    echo "FAILED: First line must be '#!/bin/sh', got: '${FIRST_LINE}'"
    exit 1
fi

# Make executable
chmod +x "${SRC_DIR}/skip.sh"

# Test 1: Basic odd lines (1, 3, 5)
echo "Test 1: Basic — lines 1, 3, 5..."
INPUT=$(printf "alpha\nbeta\ngamma\ndelta\nepsilon")
EXPECTED=$(printf "alpha\ngamma\nepsilon")
RESULT=$(echo "$INPUT" | bash "${SRC_DIR}/skip.sh")
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL"
    echo "  Expected: '$EXPECTED'"
    echo "  Got:      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 2: Single line
echo "Test 2: Single line..."
INPUT="only_line"
EXPECTED="only_line"
RESULT=$(echo "$INPUT" | bash "${SRC_DIR}/skip.sh")
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 3: Two lines (should show only first)
echo "Test 3: Two lines..."
INPUT=$(printf "first\nsecond")
EXPECTED="first"
RESULT=$(echo "$INPUT" | bash "${SRC_DIR}/skip.sh")
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 4: Numbers 1-10
echo "Test 4: Numbers 1-10 (expect 1,3,5,7,9)..."
INPUT=$(printf "1\n2\n3\n4\n5\n6\n7\n8\n9\n10")
EXPECTED=$(printf "1\n3\n5\n7\n9")
RESULT=$(echo "$INPUT" | bash "${SRC_DIR}/skip.sh")
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL"
    echo "  Expected: '$EXPECTED'"
    echo "  Got:      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 5: With ls -l style output
echo "Test 5: ls -l style output..."
INPUT=$(printf "total 42\n-rw-r--r-- 1 user group 100 file1\n-rw-r--r-- 1 user group 200 file2\n-rw-r--r-- 1 user group 300 file3")
EXPECTED=$(printf "total 42\n-rw-r--r-- 1 user group 200 file2")
RESULT=$(echo "$INPUT" | bash "${SRC_DIR}/skip.sh")
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL"
    echo "  Expected: '$EXPECTED'"
    echo "  Got:      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Results
echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"

if [ $FAIL -eq 0 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    echo "Code: $HASH"
    exit 0
else
    echo "SOME TESTS FAILED"
    exit 1
fi
