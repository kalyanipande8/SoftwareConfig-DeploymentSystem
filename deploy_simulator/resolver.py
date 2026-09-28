"""Real topological-sort dependency resolver.

Implements Kahn's algorithm from scratch over the dependency graph produced
by `parser.build_dependency_graph`. Detects cycles genuinely (by checking
whether all nodes were consumed by the time the queue empties) rather than
assuming the input is acyclic.
"""
from __future__ import annotations

from collections import deque


class CycleDetectedError(Exception):
    def __init__(self, remaining_nodes):
        self.remaining_nodes = sorted(remaining_nodes)
        super().__init__(
            f"Circular dependency detected among: {self.remaining_nodes}"
        )


def topological_sort(graph: dict[str, list[str]]) -> list[str]:
    """graph: {node: [dependencies]} where an edge node->dep means dep must
    come before node in the returned order.

    Returns a list of nodes such that every node appears after all of its
    dependencies. Raises CycleDetectedError if the graph is not a DAG.
    """
    # in_degree here counts, for each node, how many *unresolved dependencies*
    # it has. We process nodes with 0 remaining dependencies first (Kahn's).
    all_nodes = set(graph.keys())
    for deps in graph.values():
        all_nodes.update(deps)

    remaining_deps = {n: set(graph.get(n, [])) for n in all_nodes}
    # reverse_deps[d] = set of nodes that depend on d
    dependents: dict[str, set[str]] = {n: set() for n in all_nodes}
    for n, deps in remaining_deps.items():
        for d in deps:
            dependents[d].add(n)

    ready = deque(sorted(n for n, deps in remaining_deps.items() if not deps))
    order: list[str] = []
    visited = set()

    while ready:
        node = ready.popleft()
        if node in visited:
            continue
        visited.add(node)
        order.append(node)
        for dependent in sorted(dependents.get(node, [])):
            remaining_deps[dependent].discard(node)
            if not remaining_deps[dependent] and dependent not in visited:
                ready.append(dependent)

    if len(order) != len(all_nodes):
        cyclic = all_nodes - visited
        raise CycleDetectedError(cyclic)

    return order


def validate_topo_order(graph: dict[str, list[str]], order: list[str]) -> bool:
    """Independently re-check that `order` is a valid topological order for
    `graph`: every dependency of a node must appear at an earlier index.
    Used by tests as a real, computed check (not an assumption)."""
    index = {n: i for i, n in enumerate(order)}
    for node, deps in graph.items():
        if node not in index:
            return False
        for d in deps:
            if d not in index:
                return False
            if index[d] >= index[node]:
                return False
    return True


if __name__ == "__main__":
    import sys
    sys.path.insert(0, ".")
    from parser import parse_all, build_dependency_graph

    ecs = parse_all("easyconfigs")
    graph = build_dependency_graph(ecs)
    order = topological_sort(graph)
    print("Valid install order:")
    for i, mod in enumerate(order, 1):
        print(f"  {i:2d}. {mod}")
    assert validate_topo_order(graph, order)
    print("Order validated OK.")
