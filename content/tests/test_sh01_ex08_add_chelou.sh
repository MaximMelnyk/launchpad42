#!/bin/bash
# test_sh01_ex08_add_chelou.sh — hash verification
# Usage: bash test_sh01_ex08_add_chelou.sh [source_dir]
set -e

EXERCISE_ID="sh01_ex08_add_chelou"
SRC_DIR="${1:-.}"
PASS=0
FAIL=0

echo "=== Testing: ${EXERCISE_ID} ==="

# Check source file exists
if [ ! -f "${SRC_DIR}/add_chelou.sh" ]; then
    echo "FAILED: File 'add_chelou.sh' not found"
    exit 1
fi

# Check shebang
FIRST_LINE=$(head -1 "${SRC_DIR}/add_chelou.sh")
if [ "$FIRST_LINE" != "#!/bin/sh" ]; then
    echo "FAILED: First line must be '#!/bin/sh', got: '${FIRST_LINE}'"
    exit 1
fi

# Make executable
chmod +x "${SRC_DIR}/add_chelou.sh"

# Reference converter: decimal -> base 13 chelou output
# Base 13 output chars: g=0 t=1 a=2 i=3 o=4 ' '=5 l=6 u=7 S=8 n=9 e=10 m=11 f=12
dec_to_chelou13() {
    local n=$1
    if [ "$n" -eq 0 ]; then
        echo -n "g"
        return
    fi
    local chars="gtaio luSnemf"
    local result=""
    while [ "$n" -gt 0 ]; do
        local remainder=$((n % 13))
        local c="${chars:$remainder:1}"
        result="${c}${result}"
        n=$((n / 13))
    done
    echo -n "$result"
}

# FT_NBR1 encoder: decimal -> chelou base 5 (chars: '=0 \=1 "=2 ?=3 !=4)
# FT_NBR2 encoder: decimal -> chelou base 5 (chars: m=0 r=1 d=2 o=3 c=4)

# Known test cases (precalculated):
# Test 1: FT_NBR1="'" (=0), FT_NBR2="m" (=0) -> sum=0 -> "g"
# Test 2: FT_NBR1="\\" (=1), FT_NBR2="r" (=1) -> sum=2 -> "a"
# Test 3: FT_NBR1="!'" (=4*5+0=20), FT_NBR2="cm" (=4*5+0=20) -> sum=40 -> 40/13=3r1 -> "it"
# Test 4: FT_NBR1="\"?!" (=2*25+3*5+4=69), FT_NBR2="doc" (=2*25+3*5+4=69) -> sum=138 -> 138/13=10r8 -> "eS"

# Test 1: 0 + 0 = 0 -> "g"
echo "Test 1: 0 + 0 = 0 (chelou: g)..."
RESULT=$(FT_NBR1="'" FT_NBR2="m" bash "${SRC_DIR}/add_chelou.sh")
EXPECTED="g"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 2: 1 + 1 = 2 -> "a"
echo "Test 2: 1 + 1 = 2 (chelou: a)..."
RESULT=$(FT_NBR1="\\" FT_NBR2="r" bash "${SRC_DIR}/add_chelou.sh")
EXPECTED="a"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 3: 20 + 20 = 40 -> base13: 3*13+1=40 -> "it"
echo "Test 3: 20 + 20 = 40 (chelou: it)..."
RESULT=$(FT_NBR1="!'" FT_NBR2="cm" bash "${SRC_DIR}/add_chelou.sh")
EXPECTED="it"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 4: 69 + 69 = 138 -> base13: 10*13+8=138 -> "eS"
echo "Test 4: 69 + 69 = 138 (chelou: eS)..."
RESULT=$(FT_NBR1='"?!' FT_NBR2="doc" bash "${SRC_DIR}/add_chelou.sh")
EXPECTED="eS"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 5: 4 + 4 = 8 -> "S"
echo "Test 5: 4 + 4 = 8 (chelou: S)..."
RESULT=$(FT_NBR1='!' FT_NBR2="c" bash "${SRC_DIR}/add_chelou.sh")
EXPECTED="S"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
    FAIL=$((FAIL + 1))
fi

# Test 6: Larger numbers — 124 + 124 = 248 -> base13: 248=19*13+1 -> 19=1*13+6 -> "tlt"
echo "Test 6: 124 + 124 = 248 (chelou: tlt)..."
# 124 in base 5: 124 = 4*25 + 4*5 + 4 = !!!! -> wait, 4*25=100, 4*5=20, 4=4 -> 124
# FT_NBR1: !!! (=4*25+4*5+4=124) -> chars: !=4
# FT_NBR2: ccc (=4*25+4*5+4=124) -> chars: c=4
# 248 in base 13: 248/13=19r1, 19/13=1r6 -> digits 1,6,1 -> chars t,l,t -> "tlt"
RESULT=$(FT_NBR1='!!!' FT_NBR2="ccc" bash "${SRC_DIR}/add_chelou.sh")
EXPECTED="tlt"
if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Expected '$EXPECTED', Got '$RESULT'"
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
