#!/bin/bash
# test_p0_d08_vim_drills.sh — interactive checklist verification
# Usage: bash test_p0_d08_vim_drills.sh
set -e

EXERCISE_ID="p0_d08_vim_drills"

echo "=== Testing: ${EXERCISE_ID} ==="
echo ""
echo "This is an interactive checklist. Answer y/n for each task."
echo ""

TASKS=(
    "1. Can you open a file in Vim? (vim filename)"
    "2. Can you enter Insert mode? (press i)"
    "3. Can you return to Normal mode? (press Esc)"
    "4. Can you save a file? (:w)"
    "5. Can you quit Vim? (:q or :wq)"
    "6. Can you navigate with h/j/k/l?"
    "7. Can you delete a character? (x)"
    "8. Can you delete a line? (dd)"
    "9. Can you undo? (u)"
    "10. Can you copy and paste a line? (yy then p)"
    "11. Can you search for text? (/word)"
    "12. Can you replace text? (:%s/old/new/g)"
    "13. Can you use visual mode? (v or V)"
    "14. Can you open a new line below? (o)"
    "15. Did you create a .vimrc with basic settings?"
)

PASSED=0
TOTAL=${#TASKS[@]}

for task in "${TASKS[@]}"; do
    echo "$task"
    read -p "  Completed? (y/n): " answer
    if [ "$answer" == "y" ] || [ "$answer" == "Y" ]; then
        PASSED=$((PASSED + 1))
        echo "  -> OK"
    else
        echo "  -> SKIPPED"
    fi
    echo ""
done

echo "=== Result: ${PASSED}/${TOTAL} ==="

if [ "$PASSED" -ge 12 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo "ALL TESTS PASSED (${PASSED}/${TOTAL}, minimum 12)"
    echo "Code: $HASH"
    exit 0
else
    echo "FAILED: Need at least 12/${TOTAL} tasks completed, got ${PASSED}"
    exit 1
fi
