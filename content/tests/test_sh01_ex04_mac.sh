#!/bin/bash
# test_sh01_ex04_mac.sh — hash verification
# Usage: bash test_sh01_ex04_mac.sh [source_dir]
set -e

EXERCISE_ID="sh01_ex04_mac"
SRC_DIR="${1:-.}"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source file exists
if [ ! -f "${SRC_DIR}/MAC.sh" ]; then
    echo "FAILED: File 'MAC.sh' not found (note: uppercase MAC)"
    exit 1
fi

# Check shebang
FIRST_LINE=$(head -1 "${SRC_DIR}/MAC.sh")
if [ "$FIRST_LINE" != "#!/bin/sh" ]; then
    echo "FAILED: First line must be '#!/bin/sh', got: '${FIRST_LINE}'"
    exit 1
fi

# Make executable
chmod +x "${SRC_DIR}/MAC.sh"

# Get reference MAC addresses from the system
# Try ifconfig first, fallback to ip link
if command -v ifconfig >/dev/null 2>&1; then
    REFERENCE=$(ifconfig -a 2>/dev/null | grep -oE '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}' | sort)
else
    REFERENCE=$(ip link 2>/dev/null | grep -oE '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}' | sort)
fi

# Test 1: Script produces MAC addresses
echo "Test 1: Script produces output..."
RESULT=$(bash "${SRC_DIR}/MAC.sh" 2>/dev/null || true)
if [ -n "$RESULT" ]; then
    echo "  PASS (got output)"
    PASS=$((PASS + 1))
else
    echo "  FAIL: No output produced"
    echo "  Note: On WSL2, you may need to install net-tools: sudo apt install net-tools"
    FAIL=$((FAIL + 1))
fi

# Test 2: Output contains valid MAC address format
echo "Test 2: Valid MAC address format..."
MAC_REGEX='^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$'
VALID=true
while IFS= read -r line; do
    if [ -n "$line" ] && ! echo "$line" | grep -qE "$MAC_REGEX"; then
        VALID=false
        echo "  Invalid line: '$line'"
    fi
done <<< "$RESULT"

if [ "$VALID" = true ] && [ -n "$RESULT" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Output contains non-MAC lines"
    FAIL=$((FAIL + 1))
fi

# Test 3: Output matches reference (sorted comparison)
echo "Test 3: Matches system MAC addresses..."
RESULT_SORTED=$(echo "$RESULT" | sort)
if [ "$RESULT_SORTED" == "$REFERENCE" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  WARN: Output differs from reference (may be acceptable depending on method)"
    echo "  Reference: $(echo $REFERENCE | tr '\n' ' ')"
    echo "  Got:       $(echo $RESULT_SORTED | tr '\n' ' ')"
    # Count as pass if at least one MAC address matches
    COMMON=$(comm -12 <(echo "$RESULT_SORTED") <(echo "$REFERENCE") | wc -l)
    if [ "$COMMON" -gt 0 ]; then
        echo "  PASS (${COMMON} matching addresses)"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: No matching MAC addresses"
        FAIL=$((FAIL + 1))
    fi
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
