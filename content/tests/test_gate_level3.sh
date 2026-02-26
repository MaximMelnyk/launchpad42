#!/bin/bash
# test_gate_level3.sh — Phase 2→3 Gate Exam (Level 3) test runner
# Usage: bash test_gate_level3.sh [source_dir]
# Source dir should contain: ex01/ ex02/ ex03/ ex04/

EXERCISE_ID="gate_level3"
SRC_DIR="${1:-.}"

echo "========================================="
echo "  ADVANCED C GATE EXAM (LEVEL 3)"
echo "  ft_split + ft_atoi_base + ft_sort_int_tab + ft_strjoin"
echo "========================================="
echo ""

SCORE=0
TOTAL=4

# ---- Exercise 1: ft_split (single char sep) ----
echo "--- Exercise 1: ft_split ---"
EX1_DIR="${SRC_DIR}/ex01"
if [ ! -f "${EX1_DIR}/ft_split.c" ]; then
    echo "  SKIP: ex01/ft_split.c not found"
else
    # Check for forbidden functions/loops
    FORBIDDEN=0
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${EX1_DIR}/ft_split.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (printf/scanf/puts)"
        FORBIDDEN=1
    fi
    if grep -qE '\bfor\s*\(' "${EX1_DIR}/ft_split.c" 2>/dev/null; then
        echo "  FAIL: Forbidden 'for' loop (use 'while')"
        FORBIDDEN=1
    fi
    if grep -qE '\bstrtok\b|\bstrsep\b' "${EX1_DIR}/ft_split.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (strtok/strsep)"
        FORBIDDEN=1
    fi

    if [ "$FORBIDDEN" -eq 0 ]; then
        cat > /tmp/${EXERCISE_ID}_ex01_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
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

char	**ft_split(char *str, char c);

void	free_split(char **result)
{
	int	i;

	if (!result)
		return ;
	i = 0;
	while (result[i])
	{
		free(result[i]);
		i++;
	}
	free(result);
}

int	main(void)
{
	char	**r;
	int		count;

	/* Test 1: basic split */
	r = ft_split("hello world test", ' ');
	count = 0;
	if (r)
	{
		while (r[count])
		{
			ft_putchar('[');
			ft_putstr(r[count]);
			ft_putchar(']');
			count++;
		}
	}
	ft_putchar('\n');
	ft_putnbr(count);
	ft_putchar('\n');
	free_split(r);
	/* Test 2: multiple delimiters */
	r = ft_split("***a**b***", '*');
	count = 0;
	if (r)
	{
		while (r[count])
		{
			ft_putchar('[');
			ft_putstr(r[count]);
			ft_putchar(']');
			count++;
		}
	}
	ft_putchar('\n');
	ft_putnbr(count);
	ft_putchar('\n');
	free_split(r);
	/* Test 3: empty string */
	r = ft_split("", ' ');
	count = 0;
	if (r)
	{
		while (r[count])
			count++;
	}
	ft_putnbr(count);
	ft_putchar('\n');
	free_split(r);
	return (0);
}
TESTEOF
        if gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_ex01 "${EX1_DIR}/ft_split.c" /tmp/${EXERCISE_ID}_ex01_main.c 2>/dev/null; then
            RESULT=$(/tmp/${EXERCISE_ID}_ex01)
            EXPECTED=$(printf '[hello][world][test]\n3\n[a][b]\n2\n0')
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

# ---- Exercise 2: ft_atoi_base ----
echo "--- Exercise 2: ft_atoi_base ---"
EX2_DIR="${SRC_DIR}/ex02"
if [ ! -f "${EX2_DIR}/ft_atoi_base.c" ]; then
    echo "  SKIP: ex02/ft_atoi_base.c not found"
else
    FORBIDDEN=0
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${EX2_DIR}/ft_atoi_base.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (printf/scanf/puts)"
        FORBIDDEN=1
    fi
    if grep -qE '\bfor\s*\(' "${EX2_DIR}/ft_atoi_base.c" 2>/dev/null; then
        echo "  FAIL: Forbidden 'for' loop (use 'while')"
        FORBIDDEN=1
    fi
    if grep -qE '\batoi\b|\bstrtol\b|\bstrtoul\b' "${EX2_DIR}/ft_atoi_base.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (atoi/strtol/strtoul)"
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

int	ft_atoi_base(char *str, char *base);

int	main(void)
{
	/* Hex */
	ft_putnbr(ft_atoi_base("2A", "0123456789ABCDEF"));
	ft_putchar('\n');
	/* Binary */
	ft_putnbr(ft_atoi_base("101", "01"));
	ft_putchar('\n');
	/* Decimal negative */
	ft_putnbr(ft_atoi_base("  -42", "0123456789"));
	ft_putchar('\n');
	/* Zero */
	ft_putnbr(ft_atoi_base("0", "0123456789"));
	ft_putchar('\n');
	/* Invalid base (length 1) */
	ft_putnbr(ft_atoi_base("42", "0"));
	ft_putchar('\n');
	return (0);
}
TESTEOF
        if gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_ex02 "${EX2_DIR}/ft_atoi_base.c" /tmp/${EXERCISE_ID}_ex02_main.c 2>/dev/null; then
            RESULT=$(/tmp/${EXERCISE_ID}_ex02)
            EXPECTED=$(printf '42\n5\n-42\n0\n0')
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

# ---- Exercise 3: ft_sort_int_tab ----
echo "--- Exercise 3: ft_sort_int_tab ---"
EX3_DIR="${SRC_DIR}/ex03"
if [ ! -f "${EX3_DIR}/ft_sort_int_tab.c" ]; then
    echo "  SKIP: ex03/ft_sort_int_tab.c not found"
else
    FORBIDDEN=0
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${EX3_DIR}/ft_sort_int_tab.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (printf/scanf/puts)"
        FORBIDDEN=1
    fi
    if grep -qE '\bfor\s*\(' "${EX3_DIR}/ft_sort_int_tab.c" 2>/dev/null; then
        echo "  FAIL: Forbidden 'for' loop (use 'while')"
        FORBIDDEN=1
    fi
    if grep -qE '\bqsort\b' "${EX3_DIR}/ft_sort_int_tab.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (qsort)"
        FORBIDDEN=1
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

void	ft_sort_int_tab(int *tab, int size);

int	main(void)
{
	int	arr1[] = {5, 3, 1, 4, 2};
	int	arr2[] = {42, -5, 0, 100, -100};
	int	arr3[] = {1};
	int	i;

	/* Test 1: basic sort */
	ft_sort_int_tab(arr1, 5);
	i = 0;
	while (i < 5)
	{
		ft_putnbr(arr1[i]);
		ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
	/* Test 2: negative numbers */
	ft_sort_int_tab(arr2, 5);
	i = 0;
	while (i < 5)
	{
		ft_putnbr(arr2[i]);
		ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
	/* Test 3: single element */
	ft_sort_int_tab(arr3, 1);
	ft_putnbr(arr3[0]);
	ft_putchar('\n');
	/* Test 4: size 0 (should not crash) */
	ft_sort_int_tab(arr3, 0);
	ft_putnbr(arr3[0]);
	ft_putchar('\n');
	return (0);
}
TESTEOF
        if gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_ex03 "${EX3_DIR}/ft_sort_int_tab.c" /tmp/${EXERCISE_ID}_ex03_main.c 2>/dev/null; then
            RESULT=$(/tmp/${EXERCISE_ID}_ex03)
            EXPECTED=$(printf '1 2 3 4 5 \n-100 -5 0 42 100 \n1\n1')
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

# ---- Exercise 4: ft_strjoin ----
echo "--- Exercise 4: ft_strjoin ---"
EX4_DIR="${SRC_DIR}/ex04"
if [ ! -f "${EX4_DIR}/ft_strjoin.c" ]; then
    echo "  SKIP: ex04/ft_strjoin.c not found"
else
    FORBIDDEN=0
    if grep -qE '\bprintf\b|\bscanf\b|\bputs\s*\(' "${EX4_DIR}/ft_strjoin.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (printf/scanf/puts)"
        FORBIDDEN=1
    fi
    if grep -qE '\bfor\s*\(' "${EX4_DIR}/ft_strjoin.c" 2>/dev/null; then
        echo "  FAIL: Forbidden 'for' loop (use 'while')"
        FORBIDDEN=1
    fi
    if grep -qE '\bstrcat\b|\bstrncpy\b|\bstrcpy\b' "${EX4_DIR}/ft_strjoin.c" 2>/dev/null; then
        echo "  FAIL: Forbidden function (strcat/strncpy/strcpy)"
        FORBIDDEN=1
    fi

    if [ "$FORBIDDEN" -eq 0 ]; then
        cat > /tmp/${EXERCISE_ID}_ex04_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
}

char	*ft_strjoin(int size, char **strs, char *sep);

int	main(void)
{
	char	*strs[] = {"Hello", "World", "42"};
	char	*r;

	/* Test 1: basic join with space */
	r = ft_strjoin(3, strs, " ");
	if (r)
		ft_putstr(r);
	write(1, "\n", 1);
	free(r);
	/* Test 2: join with multi-char sep */
	r = ft_strjoin(3, strs, ", ");
	if (r)
		ft_putstr(r);
	write(1, "\n", 1);
	free(r);
	/* Test 3: size 0 — empty string */
	r = ft_strjoin(0, strs, " ");
	if (r)
		ft_putstr(r);
	write(1, "\n", 1);
	free(r);
	/* Test 4: size 1 — no separator */
	r = ft_strjoin(1, strs, " ");
	if (r)
		ft_putstr(r);
	write(1, "\n", 1);
	free(r);
	/* Test 5: empty separator */
	r = ft_strjoin(3, strs, "");
	if (r)
		ft_putstr(r);
	write(1, "\n", 1);
	free(r);
	return (0);
}
TESTEOF
        if gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_ex04 "${EX4_DIR}/ft_strjoin.c" /tmp/${EXERCISE_ID}_ex04_main.c 2>/dev/null; then
            RESULT=$(/tmp/${EXERCISE_ID}_ex04)
            EXPECTED=$(printf 'Hello World 42\nHello, World, 42\n\nHello\nHelloWorld42')
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
        rm -f /tmp/${EXERCISE_ID}_ex04 /tmp/${EXERCISE_ID}_ex04_main.c
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
    if [ "$SCORE" -eq 4 ]; then
        echo "PERFECT SCORE! +50 bonus XP"
    else
        echo "EXAM PASSED! Well done."
    fi
    echo "Code: $HASH"
    echo ""
    echo "Phase 3 (C10+) unlocked. Congratulations!"
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
    echo "  - ft_split: review C07 ex05 (count words, extract word, NULL-term array)"
    echo "  - ft_atoi_base: review C04 ex05 (base validation + char-to-digit mapping)"
    echo "  - ft_sort_int_tab: review C01 ex08 (bubble sort with flag)"
    echo "  - ft_strjoin: review C07 ex02 (total length calc + copy loop)"
    exit 1
fi
