#!/bin/bash
# test_sh01_ex01_print_groups.sh — hash verification
# Usage: bash test_sh01_ex01_print_groups.sh [source_dir]
set -e

EXERCISE_ID="sh01_ex01_print_groups"
SRC_DIR="${1:-.}"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source file exists
if [ ! -f "${SRC_DIR}/print_groups.sh" ]; then
    echo "FAILED: File 'print_groups.sh' not found"
    exit 1
fi

# Check shebang
FIRST_LINE=$(head -1 "${SRC_DIR}/print_groups.sh")
if [ "$FIRST_LINE" != "#!/bin/sh" ]; then
    echo "FAILED: First line must be '#!/bin/sh', got: '${FIRST_LINE}'"
    exit 1
fi

# Make executable
chmod +x "${SRC_DIR}/print_groups.sh"

# Test 1: Current user groups (FT_USER not set — defaults to current user)
echo "Test 1: Current user (no FT_USER)..."
EXPECTED=$(id -Gn | tr ' ' ',' | tr -d '\n')
RESULT=$(unset FT_USER; bash "${SRC_DIR}/print_groups.sh")
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 2: FT_USER set to current user
echo "Test 2: FT_USER=\$USER..."
EXPECTED=$(id -Gn "$USER" | tr ' ' ',' | tr -d '\n')
RESULT=$(FT_USER="$USER" bash "${SRC_DIR}/print_groups.sh")
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 3: FT_USER set to root
echo "Test 3: FT_USER=root..."
EXPECTED=$(id -Gn root | tr ' ' ',' | tr -d '\n')
RESULT=$(FT_USER="root" bash "${SRC_DIR}/print_groups.sh")
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 4: No trailing newline
echo "Test 4: No trailing newline..."
OUTPUT_BYTES=$(FT_USER="$USER" bash "${SRC_DIR}/print_groups.sh" | xxd | tail -1)
if echo "$OUTPUT_BYTES" | grep -q '0a$' 2>/dev/null; then
    # Check if output ends with 0a (newline)
    echo "  FAIL: Output has trailing newline"
    FAIL=$((FAIL + 1))
else
    echo "  PASS"
    PASS=$((PASS + 1))
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
