#!/bin/bash
# test_c_maint_04_mini_quiz.sh — hash verification
# Usage: bash test_c_maint_04_mini_quiz.sh [source_dir]
# Tests all 3 functions: ft_putchar, ft_putstr, ft_putnbr
set -e

EXERCISE_ID="c_maint_04_mini_quiz"
SRC_DIR="${1:-.}"

echo "========================================="
echo "  MINI C QUIZ — Automated Grader"
echo "========================================="
echo ""

SCORE=0
TOTAL=3

# ---- Function 1: ft_putchar ----
echo "--- Function 1: ft_putchar ---"
if [ ! -f "${SRC_DIR}/ft_putchar.c" ]; then
    echo "  SKIP: ft_putchar.c not found"
else
    # Check forbidden functions
    if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/ft_putchar.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function in ft_putchar.c"
    else
        cat > /tmp/${EXERCISE_ID}_main1.c << 'TESTEOF'
void	ft_putchar(char c);

int	main(void)
{
	ft_putchar('4');
	ft_putchar('2');
	ft_putchar('\n');
	ft_putchar('A');
	ft_putchar('z');
	ft_putchar('\n');
	return (0);
}
TESTEOF
        if gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test1 \
            "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main1.c 2>/dev/null; then
            RESULT=$(/tmp/${EXERCISE_ID}_test1)
            EXPECTED=$(printf '42\nAz')
            if [ "$RESULT" == "$EXPECTED" ]; then
                echo "  PASS"
                SCORE=$((SCORE + 1))
            else
                echo "  FAIL: Expected '42\\nAz', got '$RESULT'"
            fi
        else
            echo "  FAIL: Compilation error"
        fi
        rm -f /tmp/${EXERCISE_ID}_test1 /tmp/${EXERCISE_ID}_main1.c
    fi
fi
echo ""

# ---- Function 2: ft_putstr ----
echo "--- Function 2: ft_putstr ---"
if [ ! -f "${SRC_DIR}/ft_putstr.c" ]; then
    echo "  SKIP: ft_putstr.c not found"
else
    # Check forbidden functions
    if grep -q 'printf\|scanf\|puts(' "${SRC_DIR}/ft_putstr.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function in ft_putstr.c"
    elif grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_putstr.c" 2>/dev/null; then
        echo "  FAIL: Forbidden 'for' loop in ft_putstr.c"
    else
        cat > /tmp/${EXERCISE_ID}_main2.c << 'TESTEOF'
#include <stdlib.h>

void	ft_putstr(char *str);
void	ft_putchar(char c);

int	main(void)
{
	ft_putstr("Piscine 42");
	ft_putchar('\n');
	ft_putstr("");
	ft_putstr((void *)0);
	ft_putstr("OK\n");
	return (0);
}
TESTEOF
        if gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test2 \
            "${SRC_DIR}/ft_putstr.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main2.c 2>/dev/null; then
            RESULT=$(timeout 5 /tmp/${EXERCISE_ID}_test2 2>/dev/null) || {
                echo "  FAIL: Crashed (segfault or timeout — check NULL handling)"
                rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c
                RESULT=""
            }
            EXPECTED=$(printf 'Piscine 42\nOK')
            if [ "$RESULT" == "$EXPECTED" ]; then
                echo "  PASS"
                SCORE=$((SCORE + 1))
            elif [ -n "$RESULT" ]; then
                echo "  FAIL: Output mismatch"
                echo "  Expected: '$EXPECTED'"
                echo "  Got:      '$RESULT'"
            fi
        else
            echo "  FAIL: Compilation error"
        fi
        rm -f /tmp/${EXERCISE_ID}_test2 /tmp/${EXERCISE_ID}_main2.c
    fi
fi
echo ""

# ---- Function 3: ft_putnbr ----
echo "--- Function 3: ft_putnbr ---"
if [ ! -f "${SRC_DIR}/ft_putnbr.c" ]; then
    echo "  SKIP: ft_putnbr.c not found"
else
    # Check forbidden functions
    if grep -q 'printf\|scanf\|puts(\|itoa' "${SRC_DIR}/ft_putnbr.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function in ft_putnbr.c"
    elif grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_putnbr.c" 2>/dev/null; then
        echo "  FAIL: Forbidden 'for' loop in ft_putnbr.c"
    else
        cat > /tmp/${EXERCISE_ID}_main3.c << 'TESTEOF'
void	ft_putnbr(int nb);
void	ft_putchar(char c);

int	main(void)
{
	ft_putnbr(0);
	ft_putchar('\n');
	ft_putnbr(42);
	ft_putchar('\n');
	ft_putnbr(-42);
	ft_putchar('\n');
	ft_putnbr(2147483647);
	ft_putchar('\n');
	ft_putnbr(-2147483648);
	ft_putchar('\n');
	return (0);
}
TESTEOF
        if gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test3 \
            "${SRC_DIR}/ft_putnbr.c" "${SRC_DIR}/ft_putchar.c" /tmp/${EXERCISE_ID}_main3.c 2>/dev/null; then
            RESULT=$(/tmp/${EXERCISE_ID}_test3)
            EXPECTED=$(printf '0\n42\n-42\n2147483647\n-2147483648')
            if [ "$RESULT" == "$EXPECTED" ]; then
                echo "  PASS"
                SCORE=$((SCORE + 1))
            else
                echo "  FAIL: Output mismatch"
                echo "  Expected: '$EXPECTED'"
                echo "  Got:      '$RESULT'"
            fi
        else
            echo "  FAIL: Compilation error"
        fi
        rm -f /tmp/${EXERCISE_ID}_test3 /tmp/${EXERCISE_ID}_main3.c
    fi
fi
echo ""

# ---- Final Score ----
echo "========================================="
echo "  FINAL SCORE: ${SCORE}/${TOTAL}"
echo "========================================="

if [ "$SCORE" -eq "$TOTAL" ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo ""
    echo "ALL FUNCTIONS PASSED!"
    echo "Code: $HASH"
    echo ""
    echo "Ready for Gate Exam."
    exit 0
elif [ "$SCORE" -ge 2 ]; then
    echo ""
    echo "PARTIAL PASS: ${SCORE}/${TOTAL}"
    echo "Fix the failing function(s) and re-run."
    exit 1
else
    echo ""
    echo "NOT PASSED (need ${TOTAL}/${TOTAL})"
    echo "Review Phase 0 material and try again."
    exit 1
fi
