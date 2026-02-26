#!/bin/bash
# test_exam_sim_01.sh — Exam Simulation 1 procedure guide
# Usage: bash test_exam_sim_01.sh [source_dir]
# This is a meta-exercise (procedure guide), not a code exercise.
# The test script verifies the student completed the simulation and logged results.

EXERCISE_ID="exam_sim_01"
SRC_DIR="${1:-.}"

echo "========================================="
echo "  EXAM SIMULATION 1 — Results Checker"
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
    echo "5. Solve Level 0, 1, 2 exam tasks"
    echo "6. Create results.txt with your results"
    echo ""
    echo "Format for results.txt:"
    echo "  Level 0: PASS/FAIL - [task] - [minutes]"
    echo "  Level 1: PASS/FAIL - [task] - [minutes]"
    echo "  Level 2: PASS/FAIL - [task] - [minutes]"
    echo ""
    echo "STATUS: NOT STARTED"
    exit 1
fi

echo "Found results.txt — checking format..."
echo ""

SCORE=0
TOTAL=3

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

echo ""
echo "========================================="
echo "  EXAM RESULT: ${SCORE}/${TOTAL} levels passed"
echo "========================================="

# Any results file = simulation was attempted = exercise complete
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
if [ "$SCORE" -eq 3 ]; then
    echo "Excellent! All levels passed."
elif [ "$SCORE" -ge 1 ]; then
    echo "Simulation completed. Keep practicing!"
else
    echo "Simulation attempted. Review the failed levels and try again."
fi
echo ""
echo "SIMULATION LOGGED"
echo "Code: $HASH"
exit 0
