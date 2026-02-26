#!/bin/bash
# test_sh01_ex02_find_sh.sh — hash verification
# Usage: bash test_sh01_ex02_find_sh.sh [source_dir]
set -e

EXERCISE_ID="sh01_ex02_find_sh"
SRC_DIR="${1:-.}"
PASS=0
FAIL=0
TEST_DIR=$(mktemp -d)

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source file exists
if [ ! -f "${SRC_DIR}/find_sh.sh" ]; then
    echo "FAILED: File 'find_sh.sh' not found"
    exit 1
fi

# Check shebang
FIRST_LINE=$(head -1 "${SRC_DIR}/find_sh.sh")
if [ "$FIRST_LINE" != "#!/bin/sh" ]; then
    echo "FAILED: First line must be '#!/bin/sh', got: '${FIRST_LINE}'"
    exit 1
fi

# Make executable
chmod +x "${SRC_DIR}/find_sh.sh"

# Copy script to test directory
cp "${SRC_DIR}/find_sh.sh" "${TEST_DIR}/"

# Create test structure
mkdir -p "${TEST_DIR}/sub1" "${TEST_DIR}/sub2/deep"
touch "${TEST_DIR}/hello.sh"
touch "${TEST_DIR}/world.sh"
touch "${TEST_DIR}/sub1/deploy.sh"
touch "${TEST_DIR}/sub2/deep/utils.sh"
touch "${TEST_DIR}/readme.md"
touch "${TEST_DIR}/main.c"

# Test 1: Find all .sh files (excluding the script itself)
echo "Test 1: Find .sh files recursively..."
RESULT=$(cd "${TEST_DIR}" && bash find_sh.sh | sort)
# Expected: deploy, find_sh, hello, utils, world (sorted)
# Note: find_sh.sh itself is also a .sh file
EXPECTED=$(printf "deploy\nfind_sh\nhello\nutils\nworld" | sort)
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL"
    echo "  Expected (sorted): '$EXPECTED'"
    echo "  Got (sorted):      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 2: No .sh extension in output
echo "Test 2: No .sh extension in output..."
RESULT_RAW=$(cd "${TEST_DIR}" && bash find_sh.sh)
if echo "$RESULT_RAW" | grep -q '\.sh'; then
    echo "  FAIL: Output contains '.sh' extension"
    FAIL=$((FAIL + 1))
else
    echo "  PASS"
    PASS=$((PASS + 1))
fi

# Test 3: No path prefixes in output
echo "Test 3: No path prefixes (no ./ or /) in output..."
if echo "$RESULT_RAW" | grep -q '/'; then
    echo "  FAIL: Output contains path separators"
    FAIL=$((FAIL + 1))
else
    echo "  PASS"
    PASS=$((PASS + 1))
fi

# Test 4: Empty directory (no .sh files)
echo "Test 4: Empty directory..."
EMPTY_DIR=$(mktemp -d)
touch "${EMPTY_DIR}/test.txt"
cp "${SRC_DIR}/find_sh.sh" "${EMPTY_DIR}/"
RESULT=$(cd "${EMPTY_DIR}" && bash find_sh.sh | grep -v "find_sh" || true)
# Only find_sh itself should appear (or nothing if they exclude the script)
if [ -z "$RESULT" ] || [ "$RESULT" == "find_sh" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected empty or 'find_sh', Got '$RESULT'"
    FAIL=$((FAIL + 1))
fi
rm -rf "${EMPTY_DIR}"

# Cleanup
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
