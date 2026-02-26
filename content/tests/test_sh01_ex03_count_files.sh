#!/bin/bash
# test_sh01_ex03_count_files.sh — hash verification
# Usage: bash test_sh01_ex03_count_files.sh [source_dir]
set -e

EXERCISE_ID="sh01_ex03_count_files"
SRC_DIR="${1:-.}"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source file exists
if [ ! -f "${SRC_DIR}/count_files.sh" ]; then
    echo "FAILED: File 'count_files.sh' not found"
    exit 1
fi

# Check shebang
FIRST_LINE=$(head -1 "${SRC_DIR}/count_files.sh")
if [ "$FIRST_LINE" != "#!/bin/sh" ]; then
    echo "FAILED: First line must be '#!/bin/sh', got: '${FIRST_LINE}'"
    exit 1
fi

# Make executable
chmod +x "${SRC_DIR}/count_files.sh"

# Test 1: Known structure
echo "Test 1: Known directory structure..."
TEST_DIR=$(mktemp -d)
mkdir -p "${TEST_DIR}/sub1" "${TEST_DIR}/sub2"
touch "${TEST_DIR}/a.txt" "${TEST_DIR}/sub1/b.txt" "${TEST_DIR}/sub2/c.txt"
cp "${SRC_DIR}/count_files.sh" "${TEST_DIR}/"
# Elements: . (1) + sub1 (1) + sub2 (1) + a.txt (1) + count_files.sh (1) + sub1/b.txt (1) + sub2/c.txt (1) = 7
EXPECTED=$(cd "${TEST_DIR}" && find . | wc -l | tr -d ' ')
RESULT=$(cd "${TEST_DIR}" && bash count_files.sh)
# Strip whitespace from result
RESULT=$(echo "$RESULT" | tr -d ' \n')
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS (count: ${EXPECTED})"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '${EXPECTED}', Got '${RESULT}'"
    FAIL=$((FAIL + 1))
fi
rm -rf "${TEST_DIR}"

# Test 2: Empty directory
echo "Test 2: Empty directory..."
TEST_DIR=$(mktemp -d)
cp "${SRC_DIR}/count_files.sh" "${TEST_DIR}/"
# Elements: . (1) + count_files.sh (1) = 2
EXPECTED=$(cd "${TEST_DIR}" && find . | wc -l | tr -d ' ')
RESULT=$(cd "${TEST_DIR}" && bash count_files.sh)
RESULT=$(echo "$RESULT" | tr -d ' \n')
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS (count: ${EXPECTED})"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '${EXPECTED}', Got '${RESULT}'"
    FAIL=$((FAIL + 1))
fi
rm -rf "${TEST_DIR}"

# Test 3: Deeply nested structure
echo "Test 3: Deeply nested structure..."
TEST_DIR=$(mktemp -d)
mkdir -p "${TEST_DIR}/a/b/c/d"
touch "${TEST_DIR}/a/f1" "${TEST_DIR}/a/b/f2" "${TEST_DIR}/a/b/c/f3" "${TEST_DIR}/a/b/c/d/f4"
cp "${SRC_DIR}/count_files.sh" "${TEST_DIR}/"
EXPECTED=$(cd "${TEST_DIR}" && find . | wc -l | tr -d ' ')
RESULT=$(cd "${TEST_DIR}" && bash count_files.sh)
RESULT=$(echo "$RESULT" | tr -d ' \n')
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS (count: ${EXPECTED})"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '${EXPECTED}', Got '${RESULT}'"
    FAIL=$((FAIL + 1))
fi
rm -rf "${TEST_DIR}"

# Test 4: Output is a clean number (no extra whitespace)
echo "Test 4: Clean numeric output..."
TEST_DIR=$(mktemp -d)
touch "${TEST_DIR}/test.txt"
cp "${SRC_DIR}/count_files.sh" "${TEST_DIR}/"
RESULT=$(cd "${TEST_DIR}" && bash count_files.sh)
if echo "$RESULT" | grep -qE '^[0-9]+$'; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Output is not a clean number: '${RESULT}'"
    FAIL=$((FAIL + 1))
fi
rm -rf "${TEST_DIR}"

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
