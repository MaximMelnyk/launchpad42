#!/bin/bash
# test_exam_l4_sort_list.sh — hash verification
# Usage: bash test_exam_l4_sort_list.sh [source_dir]
set -e

EXERCISE_ID="exam_l4_sort_list"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 4: sort_list — sort linked list with cmp function)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/sort_list.c" ]; then
    echo "FAILED: File 'sort_list.c' not found"
    exit 1
fi

# Check for forbidden functions
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bmalloc\b|\bfree\b' "${SRC_DIR}/sort_list.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in sort_list.c"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/sort_list.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/sort_list.c" || {
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
	int				data;
}					t_list;

t_list	*sort_list(t_list *lst, int (*cmp)(int, int));

int	ascending(int a, int b)
{
	return (a <= b);
}

int	descending(int a, int b)
{
	return (a >= b);
}

void	ft_putnbr(int n)
{
	char	c;

	if (n < 0)
	{
		write(1, "-", 1);
		n = -n;
	}
	if (n >= 10)
		ft_putnbr(n / 10);
	c = '0' + (n % 10);
	write(1, &c, 1);
}

void	print_list(t_list *lst, int test_num)
{
	char	d;
	char	e;

	d = '0' + (test_num / 10);
	e = '0' + (test_num % 10);
	if (test_num >= 10)
		write(1, &d, 1);
	write(1, &e, 1);
	write(1, ":", 1);
	while (lst)
	{
		ft_putnbr(lst->data);
		if (lst->next)
			write(1, ",", 1);
		lst = lst->next;
	}
	write(1, " ", 1);
}

int	main(void)
{
	t_list	n1;
	t_list	n2;
	t_list	n3;
	t_list	n4;
	t_list	n5;
	t_list	*sorted;

	/* Test 1: ascending sort [5,3,1,4,2] -> [1,2,3,4,5] */
	n1.data = 5; n1.next = &n2;
	n2.data = 3; n2.next = &n3;
	n3.data = 1; n3.next = &n4;
	n4.data = 4; n4.next = &n5;
	n5.data = 2; n5.next = (void *)0;
	sorted = sort_list(&n1, &ascending);
	print_list(sorted, 1);

	/* Test 2: descending sort [1,2,3,4,5] -> [5,4,3,2,1] */
	n1.data = 1; n1.next = &n2;
	n2.data = 2; n2.next = &n3;
	n3.data = 3; n3.next = &n4;
	n4.data = 4; n4.next = &n5;
	n5.data = 5; n5.next = (void *)0;
	sorted = sort_list(&n1, &descending);
	print_list(sorted, 2);

	/* Test 3: already sorted ascending [1,2,3] */
	n1.data = 1; n1.next = &n2;
	n2.data = 2; n2.next = &n3;
	n3.data = 3; n3.next = (void *)0;
	sorted = sort_list(&n1, &ascending);
	print_list(sorted, 3);

	/* Test 4: reverse sorted -> ascending [3,2,1] -> [1,2,3] */
	n1.data = 3; n1.next = &n2;
	n2.data = 2; n2.next = &n3;
	n3.data = 1; n3.next = (void *)0;
	sorted = sort_list(&n1, &ascending);
	print_list(sorted, 4);

	/* Test 5: single element */
	n1.data = 42; n1.next = (void *)0;
	sorted = sort_list(&n1, &ascending);
	print_list(sorted, 5);

	/* Test 6: two elements swap [9,1] -> [1,9] */
	n1.data = 9; n1.next = &n2;
	n2.data = 1; n2.next = (void *)0;
	sorted = sort_list(&n1, &ascending);
	print_list(sorted, 6);

	/* Test 7: duplicates [3,1,3,1,2] -> [1,1,2,3,3] */
	n1.data = 3; n1.next = &n2;
	n2.data = 1; n2.next = &n3;
	n3.data = 3; n3.next = &n4;
	n4.data = 1; n4.next = &n5;
	n5.data = 2; n5.next = (void *)0;
	sorted = sort_list(&n1, &ascending);
	print_list(sorted, 7);

	/* Test 8: NULL list */
	sorted = sort_list((void *)0, &ascending);
	write(1, "8:", 2);
	if (sorted == (void *)0)
		write(1, "NULL ", 5);
	else
		write(1, "FAIL ", 5);

	/* Test 9: all same values [7,7,7] -> [7,7,7] */
	n1.data = 7; n1.next = &n2;
	n2.data = 7; n2.next = &n3;
	n3.data = 7; n3.next = (void *)0;
	sorted = sort_list(&n1, &ascending);
	print_list(sorted, 9);

	/* Test 10: negative numbers [-5,3,-1,0,2] ascending */
	n1.data = -5; n1.next = &n2;
	n2.data = 3; n2.next = &n3;
	n3.data = -1; n3.next = &n4;
	n4.data = 0; n4.next = &n5;
	n5.data = 2; n5.next = (void *)0;
	sorted = sort_list(&n1, &ascending);
	print_list(sorted, 10);

	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/sort_list.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:1,2,3,4,5 2:5,4,3,2,1 3:1,2,3 4:1,2,3 5:42 6:1,9 7:1,1,2,3,3 8:NULL 9:7,7,7 10:-5,-1,0,2,3 "
TOTAL=10

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  All ${TOTAL} cases PASS"
    PASS=$TOTAL
else
    echo "  Output:   '$RESULT'"
    echo "  Expected: '$EXPECTED'"
    PASS=0
    FAIL=$TOTAL
fi

rm -f /tmp/${EXERCISE_ID}_test /tmp/${EXERCISE_ID}_main.c

if [ "$RESULT" != "$EXPECTED" ]; then
    echo ""
    echo "TESTS FAILED"
    exit 1
fi

# --- All passed ---
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo ""
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
