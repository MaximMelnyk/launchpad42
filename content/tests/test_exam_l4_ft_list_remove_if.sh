#!/bin/bash
# test_exam_l4_ft_list_remove_if.sh — hash verification
# Usage: bash test_exam_l4_ft_list_remove_if.sh [source_dir]
set -e

EXERCISE_ID="exam_l4_ft_list_remove_if"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="
echo "(Exam Level 4: ft_list_remove_if — remove matching elements)"
echo ""

# Check source file exists
if [ ! -f "${SRC_DIR}/ft_list_remove_if.c" ]; then
    echo "FAILED: File 'ft_list_remove_if.c' not found"
    exit 1
fi

# Check for forbidden functions (allow free only)
if grep -qE '\bprintf\b|\bscanf\b|\bputs\b|\bmalloc\b' "${SRC_DIR}/ft_list_remove_if.c" 2>/dev/null; then
    echo "FAILED: Forbidden function in ft_list_remove_if.c"
    exit 1
fi

# Check that free is used
if ! grep -qE '\bfree\b' "${SRC_DIR}/ft_list_remove_if.c" 2>/dev/null; then
    echo "FAILED: free not found in ft_list_remove_if.c (required)"
    exit 1
fi

# Check for forbidden for loops
if grep -qE '\bfor\s*\(' "${SRC_DIR}/ft_list_remove_if.c" 2>/dev/null; then
    echo "FAILED: Forbidden 'for' loop (use 'while')"
    exit 1
fi

# Norminette check (if available)
if command -v norminette &> /dev/null; then
    echo "Running norminette..."
    norminette "${SRC_DIR}/ft_list_remove_if.c" || {
        echo "FAILED: Norminette errors found"
        exit 1
    }
fi

PASS=0
FAIL=0

echo "Compiling..."
cat > /tmp/${EXERCISE_ID}_main.c << 'TESTEOF'
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

typedef struct		s_list
{
	struct s_list	*next;
	void			*data;
}					t_list;

void	ft_list_remove_if(t_list **begin_list, void *data_ref,
			int (*cmp)(), void (*free_fct)(void *));

t_list	*new_node(char *str)
{
	t_list	*node;
	char	*dup;
	int		len;

	len = 0;
	while (str[len])
		len++;
	node = (t_list *)malloc(sizeof(t_list));
	dup = (char *)malloc(len + 1);
	len = 0;
	while (str[len])
	{
		dup[len] = str[len];
		len++;
	}
	dup[len] = '\0';
	node->data = dup;
	node->next = (void *)0;
	return (node);
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
	if (!lst)
	{
		write(1, "EMPTY ", 6);
		return ;
	}
	while (lst)
	{
		char	*s;
		int		len;

		s = (char *)lst->data;
		len = 0;
		while (s[len])
			len++;
		write(1, s, len);
		if (lst->next)
			write(1, "->", 2);
		lst = lst->next;
	}
	write(1, " ", 1);
}

void	free_all(t_list *lst)
{
	t_list	*tmp;

	while (lst)
	{
		tmp = lst->next;
		free(lst->data);
		free(lst);
		lst = tmp;
	}
}

int	main(void)
{
	t_list	*lst;
	t_list	*n;

	/* Test 1: remove from middle */
	{
		lst = new_node("A");
		lst->next = new_node("rm");
		lst->next->next = new_node("B");
		ft_list_remove_if(&lst, "rm", &strcmp, &free);
		print_list(lst, 1);
		free_all(lst);
	}
	/* Test 2: remove head */
	{
		lst = new_node("rm");
		lst->next = new_node("keep1");
		lst->next->next = new_node("keep2");
		ft_list_remove_if(&lst, "rm", &strcmp, &free);
		print_list(lst, 2);
		free_all(lst);
	}
	/* Test 3: remove tail */
	{
		lst = new_node("keep1");
		lst->next = new_node("keep2");
		lst->next->next = new_node("rm");
		ft_list_remove_if(&lst, "rm", &strcmp, &free);
		print_list(lst, 3);
		free_all(lst);
	}
	/* Test 4: remove all elements (all match) */
	{
		lst = new_node("rm");
		lst->next = new_node("rm");
		lst->next->next = new_node("rm");
		ft_list_remove_if(&lst, "rm", &strcmp, &free);
		print_list(lst, 4);
		free_all(lst);
	}
	/* Test 5: no match — nothing removed */
	{
		lst = new_node("A");
		lst->next = new_node("B");
		lst->next->next = new_node("C");
		ft_list_remove_if(&lst, "rm", &strcmp, &free);
		print_list(lst, 5);
		free_all(lst);
	}
	/* Test 6: single element, match */
	{
		lst = new_node("rm");
		ft_list_remove_if(&lst, "rm", &strcmp, &free);
		print_list(lst, 6);
		free_all(lst);
	}
	/* Test 7: single element, no match */
	{
		lst = new_node("keep");
		ft_list_remove_if(&lst, "rm", &strcmp, &free);
		print_list(lst, 7);
		free_all(lst);
	}
	/* Test 8: NULL list */
	{
		lst = (void *)0;
		ft_list_remove_if(&lst, "rm", &strcmp, &free);
		print_list(lst, 8);
	}
	/* Test 9: multiple matches (head + middle) */
	{
		lst = new_node("rm");
		lst->next = new_node("A");
		lst->next->next = new_node("rm");
		lst->next->next->next = new_node("B");
		ft_list_remove_if(&lst, "rm", &strcmp, &free);
		print_list(lst, 9);
		free_all(lst);
	}
	/* Test 10: consecutive matches at head */
	{
		lst = new_node("rm");
		lst->next = new_node("rm");
		lst->next->next = new_node("rm");
		n = new_node("keep");
		lst->next->next->next = n;
		ft_list_remove_if(&lst, "rm", &strcmp, &free);
		print_list(lst, 10);
		free_all(lst);
	}
	return (0);
}
TESTEOF

gcc -Wall -Wextra -Werror -o /tmp/${EXERCISE_ID}_test \
    "${SRC_DIR}/ft_list_remove_if.c" /tmp/${EXERCISE_ID}_main.c
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    rm -f /tmp/${EXERCISE_ID}_main.c
    exit 1
fi

RESULT=$(/tmp/${EXERCISE_ID}_test)
EXPECTED="1:A->B 2:keep1->keep2 3:keep1->keep2 4:EMPTY 5:A->B->C 6:EMPTY 7:keep 8:EMPTY 9:A->B 10:keep "
TOTAL=10

if [ "$RESULT" == "$EXPECTED" ]; then
    echo "  All ${TOTAL} cases PASS"
    PASS=$TOTAL
else
    echo "  Output:   '$RESULT'"
    echo "  Expected: '$EXPECTED'"
    PASS=$(echo "$RESULT" | tr ' ' '\n' | while read -r block; do
        echo "$EXPECTED" | tr ' ' '\n' | grep -cF "$block" 2>/dev/null
    done | paste -sd+ | bc 2>/dev/null || echo 0)
    FAIL=$((TOTAL - PASS))
    echo "  $PASS passed, $FAIL failed"
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
