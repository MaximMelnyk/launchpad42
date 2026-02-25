#!/bin/bash
# test_p0_d10_gate_exam.sh — Phase 0 Gate Exam test runner
# Usage: bash test_p0_d10_gate_exam.sh [source_dir]
# Source dir should contain: ex01/ ex02/ ex03/ ex04/ ex05/
set -e

EXERCISE_ID="p0_d10_gate_exam"
SRC_DIR="${1:-.}"

echo "========================================="
echo "  PHASE 0 GATE EXAM — Automated Grader"
echo "========================================="
echo ""

SCORE=0
TOTAL=5

# ---- Exercise 1: ft_putchar ----
echo "--- Exercise 1: ft_putchar ---"
EX1_DIR="${SRC_DIR}/ex01"
if [ ! -f "${EX1_DIR}/ft_putchar.c" ]; then
    echo "  SKIP: ex01/ft_putchar.c not found"
else
    cat > /tmp/exam_ex01_main.c << 'TESTEOF'
void	ft_putchar(char c);

int	main(void)
{
	ft_putchar('4');
	ft_putchar('2');
	ft_putchar('\n');
	return (0);
}
TESTEOF
    if gcc -Wall -Wextra -Werror -o /tmp/exam_ex01 "${EX1_DIR}/ft_putchar.c" /tmp/exam_ex01_main.c 2>/dev/null; then
        RESULT=$(/tmp/exam_ex01)
        if [ "$RESULT" == "42" ]; then
            echo "  PASS"
            SCORE=$((SCORE + 1))
        else
            echo "  FAIL: Expected '42', got '$RESULT'"
        fi
    else
        echo "  FAIL: Compilation error"
    fi
    rm -f /tmp/exam_ex01 /tmp/exam_ex01_main.c
fi
echo ""

# ---- Exercise 2: ft_putstr ----
echo "--- Exercise 2: ft_putstr ---"
EX2_DIR="${SRC_DIR}/ex02"
if [ ! -f "${EX2_DIR}/ft_putstr.c" ]; then
    echo "  SKIP: ex02/ft_putstr.c not found"
else
    cat > /tmp/exam_ex02_main.c << 'TESTEOF'
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("Piscine 42\n");
	ft_putstr("");
	ft_putstr("Done\n");
	return (0);
}
TESTEOF
    # Compile (may need ft_putchar if student uses it)
    COMPILE_FILES="${EX2_DIR}/ft_putstr.c"
    if [ -f "${EX2_DIR}/ft_putchar.c" ]; then
        COMPILE_FILES="${COMPILE_FILES} ${EX2_DIR}/ft_putchar.c"
    fi
    if gcc -Wall -Wextra -Werror -o /tmp/exam_ex02 ${COMPILE_FILES} /tmp/exam_ex02_main.c 2>/dev/null; then
        RESULT=$(/tmp/exam_ex02)
        EXPECTED=$(printf 'Piscine 42\nDone')
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
    rm -f /tmp/exam_ex02 /tmp/exam_ex02_main.c
fi
echo ""

# ---- Exercise 3: ft_putnbr ----
echo "--- Exercise 3: ft_putnbr ---"
EX3_DIR="${SRC_DIR}/ex03"
if [ ! -f "${EX3_DIR}/ft_putnbr.c" ]; then
    echo "  SKIP: ex03/ft_putnbr.c not found"
else
    cat > /tmp/exam_ex03_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_putnbr(int nb);

void	ft_putchar_nl(char c)
{
	write(1, &c, 1);
}

int	main(void)
{
	ft_putnbr(0);
	ft_putchar_nl('\n');
	ft_putnbr(42);
	ft_putchar_nl('\n');
	ft_putnbr(-42);
	ft_putchar_nl('\n');
	ft_putnbr(2147483647);
	ft_putchar_nl('\n');
	ft_putnbr(-2147483648);
	ft_putchar_nl('\n');
	return (0);
}
TESTEOF
    COMPILE_FILES="${EX3_DIR}/ft_putnbr.c"
    if [ -f "${EX3_DIR}/ft_putchar.c" ]; then
        COMPILE_FILES="${COMPILE_FILES} ${EX3_DIR}/ft_putchar.c"
    fi
    if gcc -Wall -Wextra -Werror -o /tmp/exam_ex03 ${COMPILE_FILES} /tmp/exam_ex03_main.c 2>/dev/null; then
        RESULT=$(/tmp/exam_ex03)
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
    rm -f /tmp/exam_ex03 /tmp/exam_ex03_main.c
fi
echo ""

# ---- Exercise 4: ft_print_alphabet ----
echo "--- Exercise 4: ft_print_alphabet ---"
EX4_DIR="${SRC_DIR}/ex04"
if [ ! -f "${EX4_DIR}/ft_print_alphabet.c" ]; then
    echo "  SKIP: ex04/ft_print_alphabet.c not found"
else
    cat > /tmp/exam_ex04_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_print_alphabet(void);

int	main(void)
{
	ft_print_alphabet();
	write(1, "\n", 1);
	return (0);
}
TESTEOF
    COMPILE_FILES="${EX4_DIR}/ft_print_alphabet.c"
    if [ -f "${EX4_DIR}/ft_putchar.c" ]; then
        COMPILE_FILES="${COMPILE_FILES} ${EX4_DIR}/ft_putchar.c"
    fi
    if gcc -Wall -Wextra -Werror -o /tmp/exam_ex04 ${COMPILE_FILES} /tmp/exam_ex04_main.c 2>/dev/null; then
        RESULT=$(/tmp/exam_ex04)
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
    rm -f /tmp/exam_ex04 /tmp/exam_ex04_main.c
fi
echo ""

# ---- Exercise 5: ft_print_comb ----
echo "--- Exercise 5: ft_print_comb ---"
EX5_DIR="${SRC_DIR}/ex05"
if [ ! -f "${EX5_DIR}/ft_print_comb.c" ]; then
    echo "  SKIP: ex05/ft_print_comb.c not found"
else
    cat > /tmp/exam_ex05_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_print_comb(void);

int	main(void)
{
	ft_print_comb();
	write(1, "\n", 1);
	return (0);
}
TESTEOF
    COMPILE_FILES="${EX5_DIR}/ft_print_comb.c"
    if [ -f "${EX5_DIR}/ft_putchar.c" ]; then
        COMPILE_FILES="${COMPILE_FILES} ${EX5_DIR}/ft_putchar.c"
    fi
    if gcc -Wall -Wextra -Werror -o /tmp/exam_ex05 ${COMPILE_FILES} /tmp/exam_ex05_main.c 2>/dev/null; then
        RESULT=$(/tmp/exam_ex05)
        # Verify starts with "012, 013" and ends with "789"
        STARTS_OK=0
        ENDS_OK=0
        if echo "$RESULT" | grep -q "^012, 013"; then
            STARTS_OK=1
        fi
        if echo "$RESULT" | grep -q "789$"; then
            ENDS_OK=1
        fi
        # Count expected combinations: C(10,3) = 120
        COMMA_COUNT=$(echo "$RESULT" | tr -cd ',' | wc -c)
        # 120 combinations, 119 commas
        if [ "$STARTS_OK" -eq 1 ] && [ "$ENDS_OK" -eq 1 ] && [ "$COMMA_COUNT" -eq 119 ]; then
            echo "  PASS"
            SCORE=$((SCORE + 1))
        else
            echo "  FAIL: Output verification failed"
            echo "  Starts with '012, 013': $STARTS_OK"
            echo "  Ends with '789': $ENDS_OK"
            echo "  Comma count: $COMMA_COUNT (expected 119)"
        fi
    else
        echo "  FAIL: Compilation error"
    fi
    rm -f /tmp/exam_ex05 /tmp/exam_ex05_main.c
fi
echo ""

# ---- Final Score ----
echo "========================================="
echo "  FINAL SCORE: ${SCORE}/${TOTAL}"
echo "========================================="

if [ "$SCORE" -ge 4 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo ""
    echo "EXAM PASSED!"
    if [ "$SCORE" -eq 5 ]; then
        echo "PERFECT SCORE! +50 bonus XP"
    fi
    echo "Code: $HASH"
    echo ""
    echo "Phase 1 unlocked. Congratulations!"
    exit 0
else
    echo ""
    echo "EXAM NOT PASSED (need 4/${TOTAL})"
    if [ "$SCORE" -eq 3 ]; then
        echo "Partial credit: 60% XP awarded"
    fi
    echo "You can retry in 48 hours"
    exit 1
fi
