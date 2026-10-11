#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <zakalwe/tree.h>


struct rbtree {
	RB_ENTRY(rbtree) node;
	int key;
};

static int int_compare(struct rbtree *a, struct rbtree *b);

RB_HEAD(inttree, rbtree);
RB_PROTOTYPE(inttree, rbtree, node, int_compare);
RB_GENERATE(inttree, rbtree, node, int_compare);

static int int_compare(struct rbtree *a, struct rbtree *b)
{
	if (a->key < b->key)
		return -1;
	if (b->key < a->key)
		return 1;
	return 0;
}

static void *malloc_(const size_t size)
{
	void *m = malloc(size);
	assert(m != NULL);
	return m;
}

static void test_rbtree_0(void)
{
	struct inttree *tree = malloc_(sizeof tree[0]);
	size_t i;
	struct rbtree *node;
	struct rbtree *old_node;
	struct rbtree *node1 = NULL;
	struct rbtree *next_node;

	RB_INIT(tree);
	for (i = 0; i < 10; i++) {
		node = malloc_(sizeof node[0]);
		node->key = i;
		if (i == 1)
			node1 = node; /* Used for testing later */
		old_node = RB_INSERT(inttree, tree, node);
		assert(old_node == NULL);
	}

	i = 0;
	RB_FOREACH(node, inttree, tree) {
		assert(node->key == (int) i);
		i++;
	}

	node = malloc_(sizeof node[0]);
	node->key = 1;
	old_node = RB_INSERT(inttree, tree, node);
	assert(old_node != NULL && node1 != NULL && old_node == node1);
	free(node);

	node = RB_REMOVE(inttree, tree, old_node);
	assert(node == old_node);
	free(node);

	RB_FOREACH_SAFE(node, inttree, tree, next_node) {
		old_node = RB_REMOVE(inttree, tree, node);
		assert(old_node == node);
		free(node);
	}

	RB_FOREACH_SAFE(node, inttree, tree, next_node)
		assert(0);

	free(tree);
}

int main(void)
{
	test_rbtree_0();
	return 0;
}
