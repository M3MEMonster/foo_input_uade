#include <zakalwe/base.h>
#include <zakalwe/next/digraph.h>
#include <zakalwe/mem.h>
#include <stdlib.h>

struct my_node {
	struct digraph_node node;
};

struct my_edge {
	struct digraph_edge edge;
};

DIGRAPH_PROTOTYPE(my_digraph, my_edge, edge, my_node, node)

static struct my_node *create_node(void)
{
	struct my_node *node = z_malloc_or_die(sizeof node[0]);
	return node;
}

static struct my_edge *create_edge(void)
{
	struct my_edge *edge = z_malloc_or_die(sizeof edge[0]);
	return edge;
}

static void setup_test_digraph(struct my_digraph **new_digraph,
			       struct my_digraph_reclaim *reclaim)
{
	struct my_digraph *digraph = digraph_create(my_digraph, 0);
	const size_t num_nodes = 16;
	size_t i;
	struct my_node *node;
	struct my_edge *edge;
	int ret;
	*new_digraph = NULL;
	*reclaim = digraph_reclaim_free_initializer(my_digraph);
	/* A superficial check on the structure (size) of custom reclaim. */
	z_assert(sizeof(*reclaim) == sizeof(struct digraph_opaque_reclaim));

	z_assert(digraph != NULL);
	z_assert(digraph_alloc(my_digraph, NULL, digraph, num_nodes));
	for (i = 0; i < num_nodes; i++) {
		node = create_node();
		ret = digraph_set_node(my_digraph, digraph, i, node);
		z_assert(ret);
	}
	z_assert(digraph_get_node(my_digraph, digraph, 0) != NULL);

	edge = create_edge();
	ret = digraph_set_edge(my_digraph, digraph, 0, 1, edge);
	z_assert(ret);
	z_assert(digraph_get_edge(my_digraph, digraph, 0, 1) == edge);
	z_assert(digraph_get_edge(my_digraph, digraph, 0, 2) == NULL);

	edge = create_edge();
	ret = digraph_set_edge(my_digraph, digraph, 0, 0, edge);
	z_assert(ret);
	z_assert(digraph_get_edge(my_digraph, digraph, 0, 0) == edge);

	edge = create_edge();
	ret = digraph_set_edge(my_digraph, digraph, 1, 0, edge);
	z_assert(ret);

	*new_digraph = digraph;
}

static void test_digraph_create(void)
{
	struct my_digraph *digraph;
	struct my_digraph_reclaim reclaim;
	setup_test_digraph(&digraph, &reclaim);
	digraph_free(my_digraph, digraph, &reclaim);
}

static void test_digraph_remove_edge(void)
{
	struct my_digraph *digraph;
	struct my_digraph_reclaim reclaim;
	struct my_edge *edge;
	struct my_node *node;
	setup_test_digraph(&digraph, &reclaim);
	node = digraph_get_node(my_digraph, digraph, 0);
	z_assert(node != NULL);
	edge = digraph_remove_edge(my_digraph, digraph, node, 1);
	z_assert(edge != NULL);
	z_assert(edge->edge.src == 0 && edge->edge.dst == 1);
	reclaim.free_edge(edge, NULL);

	edge = digraph_remove_edge(my_digraph, digraph, node, 1);
	z_assert(edge == NULL);

	edge = digraph_remove_edge(my_digraph, digraph, node, 0);
	z_assert(edge != NULL);
	z_assert(edge->edge.src == 0 && edge->edge.dst == 0);
	reclaim.free_edge(edge, NULL);

	digraph_free(my_digraph, digraph, &reclaim);
}

static void test_digraph_remove_node(void)
{
	struct my_digraph *digraph;
	struct my_digraph_reclaim reclaim;
	setup_test_digraph(&digraph, &reclaim);
	digraph_remove_node(my_digraph, digraph, 0, &reclaim);
	z_assert(digraph_get_node(my_digraph, digraph, 0) == NULL);
	digraph_free(my_digraph, digraph, &reclaim);
}

static void test_digraph_remove_node_edges(void)
{
	struct my_digraph *digraph;
	struct my_digraph_reclaim reclaim;
	struct my_node *node;
	setup_test_digraph(&digraph, &reclaim);
	z_assert(digraph_get_edge(my_digraph, digraph, 0, 0) != NULL);
	z_assert(digraph_get_edge(my_digraph, digraph, 0, 1) != NULL);
	digraph_remove_node_edges(my_digraph, digraph, 0, &reclaim);
	node = digraph_get_node(my_digraph, digraph, 0);
	z_assert(node != NULL);
	z_assert(node->node.num_in_edges == 0);
	z_assert(node->node.num_out_edges == 0);
	z_assert(digraph_get_edge(my_digraph, digraph, 0, 0) == NULL);
	z_assert(digraph_get_edge(my_digraph, digraph, 0, 1) == NULL);
	digraph_free(my_digraph, digraph, &reclaim);
}

static void test_digraph_iterators(void)
{
	struct my_digraph *digraph;
	struct my_digraph_reclaim reclaim;
	struct my_node *node;
	struct my_edge *edge;
	struct digraph_node_iterator node_iterator;
	struct digraph_edge_iterator edge_iterator;
	size_t index;
	setup_test_digraph(&digraph, &reclaim);
	index = 0;
	digraph_for_each_node(my_digraph, digraph, &node_iterator, node) {
		z_assert(node->node.index == index);
		index++;
	}

	node = digraph_get_node(my_digraph, digraph, 0);
	z_assert(node != NULL);
	index = 0;
	digraph_for_each_out_edge(my_digraph, node, &edge_iterator, edge) {
		size_t src = edge->edge.src;
		size_t dst = edge->edge.dst;
		if (index == 0) {
			z_assert(src == 0 && dst == 0);
		} else if (index == 1) {
			z_assert(src == 0 && dst == 1);
		} else {
			z_assert(0);
		}
		index++;
	}

	index = 0;
	digraph_for_each_in_edge(my_digraph, node, &edge_iterator, edge) {
		size_t src = edge->edge.src;
		size_t dst = edge->edge.dst;
		if (index == 0) {
			z_assert(src == 0 && dst == 0);
		} else if (index == 1) {
			z_assert(src == 1 && dst == 0);
		} else {
			z_assert(0);
		}
		index++;
	}

	digraph_free(my_digraph, digraph, &reclaim);
}

static void test_digraph_rename_node(void)
{
	struct my_digraph *digraph;
	struct my_digraph_reclaim reclaim;
	int ret;
	setup_test_digraph(&digraph, &reclaim);

	/* A no-op. */
	ret = digraph_rename_node(my_digraph, digraph, 0, 0);
	z_assert(ret);

	/* Fails because node 2 exists. */
	ret = digraph_rename_node(my_digraph, digraph, 0, 2);
	z_assert(ret == 0);

	digraph_remove_node(my_digraph, digraph, 2, &reclaim);

	z_assert(digraph_get_edge(my_digraph, digraph, 0, 0) != NULL);

	ret = digraph_rename_node(my_digraph, digraph, 0, 2);
	z_assert(ret);

	z_assert(digraph_get_node(my_digraph, digraph, 0) == NULL);
	z_assert(digraph_get_node(my_digraph, digraph, 2) != NULL);

	z_assert(digraph_get_edge(my_digraph, digraph, 2, 1) != NULL);
	z_assert(digraph_get_edge(my_digraph, digraph, 2, 2) != NULL);

	digraph_free(my_digraph, digraph, &reclaim);
}

int main(void)
{
	test_digraph_create();
	test_digraph_remove_edge();
	test_digraph_remove_node();
	test_digraph_remove_node_edges();
	test_digraph_rename_node();
	test_digraph_iterators();
	return 0;
}
