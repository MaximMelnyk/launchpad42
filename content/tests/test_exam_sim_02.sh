#!/bin/bash
# test_exam_sim_02.sh — Exam Simulation 2 procedure guide
# Usage: bash test_exam_sim_02.sh [source_dir]
# This is a meta-exercise (procedure guide), not a code exercise.
# The test script verifies the student completed the simulation and logged results.

EXERCISE_ID="exam_sim_02"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "========================================="
echo "  EXAM SIMULATION 2 — Results Checker"
echo "========================================="
echo ""

# Check if results file exists
if [ ! -f "${SRC_DIR}/results.txt" ]; then
    echo "No results.txt found."
    echo ""
    echo "To complete this exercise:"
    echo "1. Follow the exam procedure in the exercise description"
    echo "2. Set a 4-hour timer"
    echo "3. Close browser, disable internet"
    echo "4. Use ONLY Vim + gcc + man pages"
    echo "5. Solve Level 0, 1, 2, 3 exam tasks"
    echo "6. Create results.txt with your results"
    echo ""
    echo "Format for results.txt:"
    echo "  Level 0: PASS/FAIL - [task] - [minutes]"
    echo "  Level 1: PASS/FAIL - [task] - [minutes]"
    echo "  Level 2: PASS/FAIL - [task] - [minutes]"
    echo "  Level 3: PASS/FAIL - [task] - [minutes]"
    echo ""
    echo "STATUS: NOT STARTED"
    exit 1
fi

echo "Found results.txt — checking format..."
echo ""

SCORE=0
TOTAL=4

# Check Level 0
if grep -qi "Level 0.*PASS" "${SRC_DIR}/results.txt" 2>/dev/null; then
    echo "  Level 0: PASS"
    SCORE=$((SCORE + 1))
elif grep -qi "Level 0" "${SRC_DIR}/results.txt" 2>/dev/null; then
    echo "  Level 0: FAIL (logged)"
else
    echo "  Level 0: NOT FOUND in results"
fi

# Check Level 1
if grep -qi "Level 1.*PASS" "${SRC_DIR}/results.txt" 2>/dev/null; then
    echo "  Level 1: PASS"
    SCORE=$((SCORE + 1))
elif grep -qi "Level 1" "${SRC_DIR}/results.txt" 2>/dev/null; then
    echo "  Level 1: FAIL (logged)"
else
    echo "  Level 1: NOT FOUND in results"
fi

# Check Level 2
if grep -qi "Level 2.*PASS" "${SRC_DIR}/results.txt" 2>/dev/null; then
    echo "  Level 2: PASS"
    SCORE=$((SCORE + 1))
elif grep -qi "Level 2" "${SRC_DIR}/results.txt" 2>/dev/null; then
    echo "  Level 2: FAIL (logged)"
else
    echo "  Level 2: NOT FOUND in results"
fi

# Check Level 3
if grep -qi "Level 3.*PASS" "${SRC_DIR}/results.txt" 2>/dev/null; then
    echo "  Level 3: PASS"
    SCORE=$((SCORE + 1))
elif grep -qi "Level 3" "${SRC_DIR}/results.txt" 2>/dev/null; then
    echo "  Level 3: FAIL (logged)"
else
    echo "  Level 3: NOT FOUND in results"
fi

# Check for comparison with Sim 1
echo ""
if grep -qi "Comparison\|Sim 1\|simulation 1" "${SRC_DIR}/results.txt" 2>/dev/null; then
    echo "  Comparison with Sim 1: found"
else
    echo "  Comparison with Sim 1: not found (recommended!)"
fi

echo ""
echo "========================================="
echo "  EXAM RESULT: ${SCORE}/${TOTAL} levels passed"
echo "========================================="

# Any results file = simulation was attempted = exercise complete
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
if [ "$SCORE" -eq 4 ]; then
    echo "Excellent! All levels passed — significant improvement!"
elif [ "$SCORE" -ge 3 ]; then
    echo "Great result! Level 3 reached — above average for 2nd exam."
elif [ "$SCORE" -ge 2 ]; then
    echo "Solid result. Focus on Level 3 functions for next time."
elif [ "$SCORE" -ge 1 ]; then
    echo "Simulation completed. Review Levels 2-3 exercises."
else
    echo "Simulation attempted. Keep practicing — improvement comes with repetition."
fi
echo ""
echo "SIMULATION LOGGED"
    show_compile_count
echo "Code: $HASH"
exit 0
