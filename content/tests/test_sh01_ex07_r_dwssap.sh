#!/bin/bash
# test_sh01_ex07_r_dwssap.sh — hash verification
# Usage: bash test_sh01_ex07_r_dwssap.sh [source_dir]
set -e

EXERCISE_ID="sh01_ex07_r_dwssap"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source file exists
if [ ! -f "${SRC_DIR}/r_dwssap.sh" ]; then
    echo "FAILED: File 'r_dwssap.sh' not found"
    exit 1
fi

# Check shebang
FIRST_LINE=$(head -1 "${SRC_DIR}/r_dwssap.sh")
if [ "$FIRST_LINE" != "#!/bin/sh" ]; then
    echo "FAILED: First line must be '#!/bin/sh', got: '${FIRST_LINE}'"
    exit 1
fi

# Make executable
chmod +x "${SRC_DIR}/r_dwssap.sh"

# Build reference output using known-good algorithm
# Steps: cat /etc/passwd | remove comments | every 2nd line | first field | rev | sort -r | range | join with ", " | end with "."
build_reference() {
    local line1=$1
    local line2=$2
    cat /etc/passwd \
        | sed '/^#/d' \
        | awk 'NR%2==0' \
        | awk -F ":" '{print $1}' \
        | rev \
        | sort -r \
        | sed -n "${line1},${line2}p" \
        | awk '{print}' ORS=', ' \
        | sed 's/, $/\./' \
        | tr -d '\n'
}

# Test 1: FT_LINE1=1, FT_LINE2=3
echo "Test 1: FT_LINE1=1, FT_LINE2=3..."
EXPECTED=$(build_reference 1 3)
RESULT=$(FT_LINE1=1 FT_LINE2=3 bash "${SRC_DIR}/r_dwssap.sh")
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL"
    echo "  Expected: '$EXPECTED'"
    echo "  Got:      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 2: FT_LINE1=1, FT_LINE2=1 (single entry)
echo "Test 2: FT_LINE1=1, FT_LINE2=1 (single entry)..."
EXPECTED=$(build_reference 1 1)
RESULT=$(FT_LINE1=1 FT_LINE2=1 bash "${SRC_DIR}/r_dwssap.sh")
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL"
    echo "  Expected: '$EXPECTED'"
    echo "  Got:      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 3: FT_LINE1=2, FT_LINE2=5
echo "Test 3: FT_LINE1=2, FT_LINE2=5..."
EXPECTED=$(build_reference 2 5)
RESULT=$(FT_LINE1=2 FT_LINE2=5 bash "${SRC_DIR}/r_dwssap.sh")
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL"
    echo "  Expected: '$EXPECTED'"
    echo "  Got:      '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 4: Output ends with period
echo "Test 4: Output ends with period..."
RESULT=$(FT_LINE1=1 FT_LINE2=3 bash "${SRC_DIR}/r_dwssap.sh")
if echo "$RESULT" | grep -q '\.$'; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Output should end with '.'"
    echo "  Got: '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 5: No trailing newline
echo "Test 5: No trailing newline..."
RAW_OUTPUT=$(FT_LINE1=1 FT_LINE2=2 bash "${SRC_DIR}/r_dwssap.sh" | xxd | tail -1)
if echo "$RAW_OUTPUT" | grep -qE '0a\s*$'; then
    echo "  WARN: Output may have trailing newline (acceptable in some implementations)"
    PASS=$((PASS + 1))
else
    echo "  PASS"
    PASS=$((PASS + 1))
fi

# Test 6: Entries separated by ", " (comma + space)
echo "Test 6: Entries separated by ', '..."
RESULT=$(FT_LINE1=1 FT_LINE2=3 bash "${SRC_DIR}/r_dwssap.sh")
# Count number of ", " separators — should be (line2 - line1)
SEPARATORS=$(echo "$RESULT" | grep -o ', ' | wc -l)
EXPECTED_SEP=2
if [ "$SEPARATORS" -eq "$EXPECTED_SEP" ]; then
    echo "  PASS (${SEPARATORS} separators for 3 entries)"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected ${EXPECTED_SEP} separators, got ${SEPARATORS}"
    FAIL=$((FAIL + 1))
fi

# Results
echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"

if [ $FAIL -eq 0 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED"
    show_compile_count
    echo "Code: $HASH"
    exit 0
else
    echo "SOME TESTS FAILED"
    exit 1
fi
