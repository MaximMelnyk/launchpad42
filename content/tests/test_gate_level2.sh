#!/bin/bash
# test_gate_level2.sh — Phase 2 Gate Exam (Level 2) test runner
# Usage: bash test_gate_level2.sh [source_dir]
# Source dir should contain: ex01/ ex02/ ex03/
set -e

EXERCISE_ID="gate_level2"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "========================================="
echo "  C CORE GATE EXAM (LEVEL 2)"
echo "  ft_strcmp + ft_atoi + ft_recursive_factorial"
echo "========================================="
echo ""

SCORE=0
TOTAL=3

# ---- Exercise 1: ft_strcmp ----
echo "--- Exercise 1: ft_strcmp ---"
EX1_DIR="${SRC_DIR}/ex01"
if [ ! -f "${EX1_DIR}/ft_strcmp.c" ]; then
    echo "  SKIP: ex01/ft_strcmp.c not found"
else
    # Check for forbidden functions/loops
    FORBIDDEN=0
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${EX1_DIR}/ft_strcmp.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (printf/scanf/puts)"
        FORBIDDEN=1
    fi
    if grep -qE '\bfor\s*\(' "${EX1_DIR}/ft_strcmp.c" 2>/dev/null; then
        echo "  FAIL: Forbidden 'for' loop (use 'while')"
        FORBIDDEN=1
    fi
    if grep -qE '\bstrcmp\s*\(' "${EX1_DIR}/ft_strcmp.c" 2>/dev/null; then
        echo "  FAIL: Forbidden 'strcmp' (write your own!)"
        FORBIDDEN=1
    fi

    if [ "$FORBIDDEN" -eq 0 ]; then
        cat > /tmp/${EXERCISE_ID}_ex01_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
	if (nb == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (nb < 0)
	{
		ft_putchar('-');
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}

int	ft_strcmp(char *s1, char *s2);

int	main(void)
{
	int	r;

	/* Test 1: equal strings */
	r = ft_strcmp("abc", "abc");
	ft_putnbr(r);
	ft_putchar('\n');
	/* Test 2: s1 < s2 */
	r = ft_strcmp("abc", "abd");
	if (r < 0)
		ft_putchar('-');
	else
		ft_putchar('+');
	ft_putchar('\n');
	/* Test 3: s1 > s2 */
	r = ft_strcmp("abd", "abc");
	if (r > 0)
		ft_putchar('+');
	else
		ft_putchar('-');
	ft_putchar('\n');
	/* Test 4: empty strings */
	r = ft_strcmp("", "");
	ft_putnbr(r);
	ft_putchar('\n');
	/* Test 5: one empty */
	r = ft_strcmp("abc", "");
	if (r > 0)
		ft_putchar('+');
	else
		ft_putchar('-');
	ft_putchar('\n');
	return (0);
}
TESTEOF
        if gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_ex01 "${EX1_DIR}/ft_strcmp.c" /tmp/${EXERCISE_ID}_ex01_main.c 2>/dev/null; then
            RESULT=$(/tmp/${EXERCISE_ID}_ex01)
            EXPECTED=$(printf '0\n-\n+\n0\n+')
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
        rm -f /tmp/${EXERCISE_ID}_ex01 /tmp/${EXERCISE_ID}_ex01_main.c
    fi
fi
echo ""

# ---- Exercise 2: ft_atoi ----
echo "--- Exercise 2: ft_atoi ---"
EX2_DIR="${SRC_DIR}/ex02"
if [ ! -f "${EX2_DIR}/ft_atoi.c" ]; then
    echo "  SKIP: ex02/ft_atoi.c not found"
else
    FORBIDDEN=0
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${EX2_DIR}/ft_atoi.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (printf/scanf/puts)"
        FORBIDDEN=1
    fi
    if grep -qE '\bfor\s*\(' "${EX2_DIR}/ft_atoi.c" 2>/dev/null; then
        echo "  FAIL: Forbidden 'for' loop (use 'while')"
        FORBIDDEN=1
    fi
    if grep -qE '\batoi\s*\(|\bstrtol\s*\(' "${EX2_DIR}/ft_atoi.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (atoi/strtol)"
        FORBIDDEN=1
    fi

    if [ "$FORBIDDEN" -eq 0 ]; then
        cat > /tmp/${EXERCISE_ID}_ex02_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
	if (nb == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (nb < 0)
	{
		ft_putchar('-');
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}

int	ft_atoi(char *str);

int	main(void)
{
	ft_putnbr(ft_atoi("42"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("  -42"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("  ---42"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("0"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("abc"));
	ft_putchar('\n');
	return (0);
}
TESTEOF
        if gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_ex02 "${EX2_DIR}/ft_atoi.c" /tmp/${EXERCISE_ID}_ex02_main.c 2>/dev/null; then
            RESULT=$(/tmp/${EXERCISE_ID}_ex02)
            EXPECTED=$(printf '42\n-42\n42\n0\n0')
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
        rm -f /tmp/${EXERCISE_ID}_ex02 /tmp/${EXERCISE_ID}_ex02_main.c
    fi
fi
echo ""

# ---- Exercise 3: ft_recursive_factorial ----
echo "--- Exercise 3: ft_recursive_factorial ---"
EX3_DIR="${SRC_DIR}/ex03"
if [ ! -f "${EX3_DIR}/ft_recursive_factorial.c" ]; then
    echo "  SKIP: ex03/ft_recursive_factorial.c not found"
else
    FORBIDDEN=0
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${EX3_DIR}/ft_recursive_factorial.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (printf/scanf/puts)"
        FORBIDDEN=1
    fi
    if grep -qE '\bfor\s*\(' "${EX3_DIR}/ft_recursive_factorial.c" 2>/dev/null; then
        echo "  FAIL: Forbidden 'for' loop (use 'while')"
        FORBIDDEN=1
    fi
    # Check for recursion (function should call itself)
    if ! grep -qE '\bft_recursive_factorial\s*\(' "${EX3_DIR}/ft_recursive_factorial.c" 2>/dev/null; then
        echo "  WARNING: Function may not be recursive"
    fi

    if [ "$FORBIDDEN" -eq 0 ]; then
        cat > /tmp/${EXERCISE_ID}_ex03_main.c << 'TESTEOF'
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
	if (nb == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (nb < 0)
	{
		ft_putchar('-');
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}

int	ft_recursive_factorial(int nb);

int	main(void)
{
	ft_putnbr(ft_recursive_factorial(5));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_factorial(0));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_factorial(10));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_factorial(-3));
	ft_putchar('\n');
	return (0);
}
TESTEOF
        if gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_ex03 "${EX3_DIR}/ft_recursive_factorial.c" /tmp/${EXERCISE_ID}_ex03_main.c 2>/dev/null; then
            RESULT=$(/tmp/${EXERCISE_ID}_ex03)
            EXPECTED=$(printf '120\n1\n3628800\n0')
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
        rm -f /tmp/${EXERCISE_ID}_ex03 /tmp/${EXERCISE_ID}_ex03_main.c
    fi
fi
echo ""

# ---- Final Score ----
echo "========================================="
echo "  FINAL SCORE: ${SCORE}/${TOTAL}"
echo "========================================="

if [ "$SCORE" -ge 2 ]; then
    HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
    echo ""
    if [ "$SCORE" -eq 3 ]; then
        echo "PERFECT SCORE! +50 bonus XP"
    else
        echo "EXAM PASSED! Well done."
    fi
    show_compile_count
    echo "Code: $HASH"
    echo ""
    echo "C06+ unlocked. Congratulations!"
    exit 0
else
    echo ""
    if [ "$SCORE" -eq 1 ]; then
        echo "NOT PASSED (need 2/${TOTAL})"
        echo "Partial credit: 60% XP awarded"
    else
        echo "NOT PASSED (need 2/${TOTAL})"
    fi
    echo "You can retry in 48 hours."
    echo ""
    echo "Focus areas:"
    echo "  - ft_strcmp: review C03 ex00 (while loop + unsigned char comparison)"
    echo "  - ft_atoi: review C04 ex03 (whitespace skip + sign handling + digit parsing)"
    echo "  - ft_recursive_factorial: review C05 ex01 (base case + recursive call)"
    exit 1
fi
