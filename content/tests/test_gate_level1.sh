#!/bin/bash
# test_gate_level1.sh — Phase 1 Gate Exam test runner
# Usage: bash test_gate_level1.sh [source_dir]
# Source dir should contain: ex01/ ex02/ ex03/ ex04/ ex05/
set -e

EXERCISE_ID="gate_level1"
SRC_DIR="${1:-.}"

echo "========================================="
echo "  PHASE 1 GATE EXAM — Automated Grader"
echo "  Shell & Git Gate Exam"
echo "========================================="
echo ""

SCORE=0
TOTAL=5

# ---- Exercise 1: File Permissions ----
echo "--- Exercise 1: File Permissions ---"
EX1_DIR="${SRC_DIR}/ex01"
if [ ! -f "${EX1_DIR}/ready" ]; then
    echo "  SKIP: ex01/ready not found"
else
    PERMS=$(stat -c "%A" "${EX1_DIR}/ready" 2>/dev/null || stat -f "%Sp" "${EX1_DIR}/ready" 2>/dev/null)
    if [ "$PERMS" == "-rwxr-x--x" ]; then
        echo "  PASS"
        SCORE=$((SCORE + 1))
    else
        echo "  FAIL: Expected permissions '-rwxr-x--x', got '$PERMS'"
        echo "  Hint: chmod 751 ex01/ready"
    fi
fi
echo ""

# ---- Exercise 2: ls one-liner ----
echo "--- Exercise 2: ls one-liner ---"
EX2_DIR="${SRC_DIR}/ex02"
if [ ! -f "${EX2_DIR}/midLS.sh" ]; then
    echo "  SKIP: ex02/midLS.sh not found"
else
    # Check that file contains only an ls command (no shebang, no echo, etc.)
    LINE_COUNT=$(wc -l < "${EX2_DIR}/midLS.sh" | tr -d ' ')
    CONTENT=$(cat "${EX2_DIR}/midLS.sh" | grep -v '^$' | head -1)

    if ! echo "$CONTENT" | grep -q '^ls'; then
        echo "  FAIL: File must contain an ls command"
    else
        # Check required flags: -a (or -A), -1 (one per line), -t (time sort), -p or -F (indicator)
        HAS_HIDDEN=0
        HAS_ONE_PER_LINE=0
        HAS_TIME_SORT=0
        HAS_INDICATOR=0

        if echo "$CONTENT" | grep -qE '\-[^ ]*A'; then
            HAS_HIDDEN=1
        fi
        if echo "$CONTENT" | grep -qE '\-[^ ]*1'; then
            HAS_ONE_PER_LINE=1
        fi
        if echo "$CONTENT" | grep -qE '\-[^ ]*t'; then
            HAS_TIME_SORT=1
        fi
        if echo "$CONTENT" | grep -qE '\-[^ ]*(p|F)'; then
            HAS_INDICATOR=1
        fi

        PASS_COUNT=$((HAS_HIDDEN + HAS_ONE_PER_LINE + HAS_TIME_SORT + HAS_INDICATOR))
        if [ "$PASS_COUNT" -ge 3 ]; then
            echo "  PASS"
            SCORE=$((SCORE + 1))
        else
            echo "  FAIL: Missing required flags"
            echo "  Hidden files (-A): $HAS_HIDDEN"
            echo "  One per line (-1): $HAS_ONE_PER_LINE"
            echo "  Time sort (-t): $HAS_TIME_SORT"
            echo "  Indicator (-p or -F): $HAS_INDICATOR"
            echo "  Need at least 3 of 4 flags"
        fi
    fi
fi
echo ""

# ---- Exercise 3: Git workflow ----
echo "--- Exercise 3: Git workflow ---"
EX3_DIR="${SRC_DIR}/ex03"
if [ ! -d "${EX3_DIR}/.git" ]; then
    echo "  SKIP: ex03/ is not a git repository"
else
    # Check commits
    COMMIT_COUNT=$(cd "${EX3_DIR}" && git log --oneline 2>/dev/null | wc -l | tr -d ' ')
    HAS_FEATURE=$(cd "${EX3_DIR}" && git branch 2>/dev/null | grep -c 'feature' || true)
    HAS_HELLO=$([ -f "${EX3_DIR}/hello.c" ] && echo 1 || echo 0)
    HAS_MAKEFILE=$([ -f "${EX3_DIR}/Makefile" ] && echo 1 || echo 0)

    # Check feature branch commits
    FEATURE_COMMITS=0
    if [ "$HAS_FEATURE" -ge 1 ]; then
        FEATURE_COMMITS=$(cd "${EX3_DIR}" && git log feature --oneline 2>/dev/null | wc -l | tr -d ' ')
    fi

    GIT_PASS=1
    REASONS=""

    if [ "$COMMIT_COUNT" -lt 2 ]; then
        GIT_PASS=0
        REASONS="${REASONS}  Need at least 2 commits on current branch (got $COMMIT_COUNT)\n"
    fi
    if [ "$HAS_FEATURE" -lt 1 ]; then
        GIT_PASS=0
        REASONS="${REASONS}  Branch 'feature' not found\n"
    fi
    if [ "$HAS_HELLO" -eq 0 ]; then
        GIT_PASS=0
        REASONS="${REASONS}  File 'hello.c' not found\n"
    fi
    if [ "$HAS_MAKEFILE" -eq 0 ]; then
        GIT_PASS=0
        REASONS="${REASONS}  File 'Makefile' not found\n"
    fi

    if [ "$GIT_PASS" -eq 1 ]; then
        echo "  PASS"
        SCORE=$((SCORE + 1))
    else
        echo "  FAIL:"
        printf "$REASONS"
    fi
fi
echo ""

# ---- Exercise 4: Makefile ----
echo "--- Exercise 4: Makefile ---"
EX4_DIR="${SRC_DIR}/ex04"
if [ ! -f "${EX4_DIR}/Makefile" ]; then
    echo "  SKIP: ex04/Makefile not found"
else
    MAKEFILE_PASS=1
    REASONS=""

    # Check Makefile has required rules
    if ! grep -q 'all' "${EX4_DIR}/Makefile"; then
        MAKEFILE_PASS=0
        REASONS="${REASONS}  Missing rule: all\n"
    fi
    if ! grep -q 'clean' "${EX4_DIR}/Makefile"; then
        MAKEFILE_PASS=0
        REASONS="${REASONS}  Missing rule: clean\n"
    fi
    if ! grep -q 'fclean' "${EX4_DIR}/Makefile"; then
        MAKEFILE_PASS=0
        REASONS="${REASONS}  Missing rule: fclean\n"
    fi
    if ! grep -qE '^\s*re\s*:' "${EX4_DIR}/Makefile" && ! grep -q '^re:' "${EX4_DIR}/Makefile"; then
        # Also check for 're' as a target
        if ! grep -q 're' "${EX4_DIR}/Makefile"; then
            MAKEFILE_PASS=0
            REASONS="${REASONS}  Missing rule: re\n"
        fi
    fi
    if ! grep -q '\-Wall' "${EX4_DIR}/Makefile"; then
        MAKEFILE_PASS=0
        REASONS="${REASONS}  Missing flag: -Wall\n"
    fi
    if ! grep -q '\-Wextra' "${EX4_DIR}/Makefile"; then
        MAKEFILE_PASS=0
        REASONS="${REASONS}  Missing flag: -Wextra\n"
    fi
    if ! grep -q '\-Werror' "${EX4_DIR}/Makefile"; then
        MAKEFILE_PASS=0
        REASONS="${REASONS}  Missing flag: -Werror\n"
    fi

    # Try to build if source files exist
    if [ "$MAKEFILE_PASS" -eq 1 ] && [ -f "${EX4_DIR}/ft_putstr.c" ] && [ -f "${EX4_DIR}/ft_putchar.c" ] && [ -f "${EX4_DIR}/main.c" ]; then
        BUILD_RESULT=$(cd "${EX4_DIR}" && make 2>&1) || {
            MAKEFILE_PASS=0
            REASONS="${REASONS}  make failed: ${BUILD_RESULT}\n"
        }

        # Check if executable was created
        if [ "$MAKEFILE_PASS" -eq 1 ]; then
            EXEC_NAME=$(grep -oP 'NAME\s*=\s*\K\S+' "${EX4_DIR}/Makefile" 2>/dev/null || echo "putstr_prog")
            if [ -f "${EX4_DIR}/${EXEC_NAME}" ]; then
                RUN_RESULT=$(cd "${EX4_DIR}" && "./${EXEC_NAME}" 2>/dev/null) || true
                if echo "$RUN_RESULT" | grep -q "Makefile works"; then
                    echo "  Build and run: OK"
                fi
            fi
        fi

        # Cleanup
        (cd "${EX4_DIR}" && make fclean 2>/dev/null) || true
    fi

    if [ "$MAKEFILE_PASS" -eq 1 ]; then
        echo "  PASS"
        SCORE=$((SCORE + 1))
    else
        echo "  FAIL:"
        printf "$REASONS"
    fi
fi
echo ""

# ---- Exercise 5: ft_print_alphabet from memory ----
echo "--- Exercise 5: ft_print_alphabet ---"
EX5_DIR="${SRC_DIR}/ex05"
if [ ! -f "${EX5_DIR}/ft_print_alphabet.c" ]; then
    echo "  SKIP: ex05/ft_print_alphabet.c not found"
else
    # Check for forbidden functions/loops
    FORBIDDEN=0
    if grep -q 'printf\|scanf\|puts(' "${EX5_DIR}/ft_print_alphabet.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (printf/scanf/puts)"
        FORBIDDEN=1
    fi
    if grep -qE '\bfor\s*\(' "${EX5_DIR}/ft_print_alphabet.c" 2>/dev/null; then
        echo "  FAIL: Forbidden 'for' loop (use 'while')"
        FORBIDDEN=1
    fi

    if [ "$FORBIDDEN" -eq 0 ]; then
        cat > /tmp/${EXERCISE_ID}_ex05_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_print_alphabet(void);

int	main(void)
{
	ft_print_alphabet();
	write(1, "\n", 1);
	return (0);
}
TESTEOF
        COMPILE_FILES="${EX5_DIR}/ft_print_alphabet.c"
        if [ -f "${EX5_DIR}/ft_putchar.c" ]; then
            COMPILE_FILES="${COMPILE_FILES} ${EX5_DIR}/ft_putchar.c"
        fi
        if gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_ex05 ${COMPILE_FILES} /tmp/${EXERCISE_ID}_ex05_main.c 2>/dev/null; then
            RESULT=$(/tmp/${EXERCISE_ID}_ex05)
            EXPECTED="abcdefghijklmnopqrstuvwxyz"
            if [ "$RESULT" == "$EXPECTED" ]; then
                echo "  PASS"
                SCORE=$((SCORE + 1))
            else
                echo "  FAIL: Expected '$EXPECTED', got '$RESULT'"
            fi
        else
            echo "  FAIL: Compilation error"
        fi
        rm -f /tmp/${EXERCISE_ID}_ex05 /tmp/${EXERCISE_ID}_ex05_main.c
    fi
fi
echo ""

# ---- Final Score ----
echo "========================================="
echo "  FINAL SCORE: ${SCORE}/${TOTAL}"
echo "========================================="

if [ "$SCORE" -ge 3 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo ""
    if [ "$SCORE" -eq 5 ]; then
        echo "PERFECT SCORE! +50 bonus XP"
    elif [ "$SCORE" -eq 4 ]; then
        echo "EXAM PASSED! Well done."
    else
        echo "EXAM PASSED. Minimum threshold reached."
    fi
    echo "Code: $HASH"
    echo ""
    echo "Phase 2 unlocked. Congratulations!"
    exit 0
else
    echo ""
    if [ "$SCORE" -eq 2 ]; then
        echo "NOT PASSED (need 3/${TOTAL})"
        echo "Partial credit: 60% XP awarded"
    else
        echo "NOT PASSED (need 3/${TOTAL})"
    fi
    echo "You can retry in 48 hours."
    echo ""
    echo "Focus areas:"
    echo "  - Shell: review Phase 1 shell exercises"
    echo "  - Git: practice git init/commit/branch workflow"
    echo "  - Makefile: review Makefile structure (NAME, CC, CFLAGS, rules)"
    echo "  - C: review Phase 0 C exercises"
    exit 1
fi
