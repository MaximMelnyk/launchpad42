#!/bin/bash
# test_exam_l4_ft_list_foreach.sh — hash verification
# Usage: bash test_exam_l4_ft_list_foreach.sh [source_dir]
set -e

EXERCISE_ID="exam_l4_ft_list_foreach"
SRC_DIR="${1:-.}"
# Track compilation attempts
_HELPERS="$(dirname "$0")/_helpers.sh"
[ -f "$_HELPERS" ] && . "$_HELPERS" && track_compile "$EXERCISE_ID" "$SRC_DIR"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 4: ft_list_foreach — apply function to list)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_list_foreach.c" ]; then
    echo "FAILED: File 'ft_list_foreach.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bmalloc\b|\bfree\b' "${SRC_DIR}/ft_list_foreach.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_list_foreach.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_list_foreach.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_list_foreach.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

echo "Compiling..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>

typedef struct		s_list
{
	struct s_list	*next;
	void			*data;
}					t_list;

void	ft_list_foreach(t_list *begin_list, void (*f)(void *));

/* Helper: print string data */
void	print_str(void *data)
{
	char	*s;
	int		i;

	s = (char *)data;
	i = 0;
	while (s[i])
		i++;
	write(1, s, i);
}

/* Helper: increment int data */
void	inc_int(void *data)
{
	(*(int *)data)++;
}

void	ft_putnbr(int n)
{
	char	c;

	if (n >= 10)
		ft_putnbr(n / 10);
	c = '0' + (n % 10);
	write(1, &c, 1);
}

int	main(void)
{
	t_list	n1;
	t_list	n2;
	t_list	n3;
	t_list	n4;
	int		a;
	int		b;
	int		c;

	/* Test 1: print strings from 3-element list */
	write(1, "1:", 2);
	n1.data = "Hello";
	n1.next = &n2;
	n2.data = " World";
	n2.next = &n3;
	n3.data = "!";
	n3.next = (void *)0;
	ft_list_foreach(&n1, &print_str);
	write(1, " ", 1);

	/* Test 2: single element */
	write(1, "2:", 2);
	n1.data = "Solo";
	n1.next = (void *)0;
	ft_list_foreach(&n1, &print_str);
	write(1, " ", 1);

	/* Test 3: NULL list */
	write(1, "3:", 2);
	ft_list_foreach((void *)0, &print_str);
	write(1, "OK ", 3);

	/* Test 4: increment integers */
	write(1, "4:", 2);
	a = 10;
	b = 20;
	c = 30;
	n1.data = &a;
	n1.next = &n2;
	n2.data = &b;
	n2.next = &n3;
	n3.data = &c;
	n3.next = (void *)0;
	ft_list_foreach(&n1, &inc_int);
	ft_putnbr(a);
	write(1, ",", 1);
	ft_putnbr(b);
	write(1, ",", 1);
	ft_putnbr(c);
	write(1, " ", 1);

	/* Test 5: 4-element string list */
	write(1, "5:", 2);
	n1.data = "A";
	n1.next = &n2;
	n2.data = "B";
	n2.next = &n3;
	n3.data = "C";
	n3.next = &n4;
	n4.data = "D";
	n4.next = (void *)0;
	ft_list_foreach(&n1, &print_str);
	write(1, " ", 1);

	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_list_foreach.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:Hello World! 2:Solo 3:OK 4:11,21,31 5:ABCD "

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  All 5 cases PASS"
    PASS=5
else
    echo "  Output:   '$RESULT'"
    echo "  Expected: '$EXPECTED'"
    FAIL=1
fi

rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c

if [ $FAIL -ne 0 ]; then
    echo ""
    echo "TESTS FAILED"
    exit 1
fi

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
    show_compile_count
echo "Code: $HASH"
exit 0
