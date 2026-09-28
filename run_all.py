#!/usr/bin/env python3
"""Orchestrates the full, real pipeline:

    parse .eb files -> build dependency graph -> topological resolve
    -> simulate deployment across 4 clusters -> write report + figure

Run with:  python3 run_all.py
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "deploy_simulator"))

from parser import parse_all, build_dependency_graph  # noqa: E402
from resolver import topological_sort, validate_topo_order  # noqa: E402
from simulate_deployment import run_full_simulation, EASYCONFIGS_DIR  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(REPO_ROOT, "output")
FIGURES_DIR = os.path.join(OUTPUT_DIR, "figures")


def make_figure(graph: dict, order: list[str]):
    os.makedirs(FIGURES_DIR, exist_ok=True)
    fig_path = os.path.join(FIGURES_DIR, "dependency_graph.png")
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt

        # Simple layered layout by topological "depth" (longest path from a root).
        depth = {n: 0 for n in graph}
        for n in order:
            for dep in graph.get(n, []):
                depth[n] = max(depth[n], depth[dep] + 1)

        layers: dict[int, list[str]] = {}
        for n, d in depth.items():
            layers.setdefault(d, []).append(n)
        for d in layers:
            layers[d].sort()

        pos = {}
        for d, nodes in layers.items():
            for i, n in enumerate(nodes):
                pos[n] = (d, i - len(nodes) / 2)

        fig, ax = plt.subplots(figsize=(16, 10))
        for n, deps in graph.items():
            for dep in deps:
                x1, y1 = pos[dep]
                x2, y2 = pos[n]
                ax.plot([x1, x2], [y1, y2], color="#999999", linewidth=0.6, zorder=1)

        for n, (x, y) in pos.items():
            ax.scatter([x], [y], s=260, color="#2b6cb0", zorder=2)
            ax.annotate(n, (x, y), textcoords="offset points", xytext=(0, 8),
                        ha="center", fontsize=6.5, zorder=3)

        ax.set_title("EasyBuild dependency graph (28 packages) -- layered by build depth")
        ax.set_xlabel("build depth (0 = no deps in this set)")
        ax.get_yaxis().set_visible(False)
        for spine in ("top", "right", "left"):
            ax.spines[spine].set_visible(False)
        plt.tight_layout()
        plt.savefig(fig_path, dpi=140)
        plt.close(fig)
        return fig_path
    except Exception as exc:  # pragma: no cover - fallback path
        # Fall back to a plain text rendering of the order if plotting fails.
        txt_path = os.path.join(FIGURES_DIR, "install_order.txt")
        with open(txt_path, "w") as f:
            f.write(f"(matplotlib figure generation failed: {exc})\n\n")
            f.write("Resolved install order:\n")
            for i, n in enumerate(order, 1):
                f.write(f"{i:2d}. {n}\n")
        return txt_path


def write_report(summary: dict, fig_path: str):
    report_path = os.path.join(OUTPUT_DIR, "report.md")
    lines = []
    lines.append("# Deployment Simulation Report\n")
    lines.append(f"Packages parsed: **{summary['num_packages_parsed']}**\n")
    lines.append("## Resolved install order\n")
    for i, m in enumerate(summary["install_order"], 1):
        lines.append(f"{i}. `{m}`")
    lines.append("")
    lines.append("## Per-cluster deployment results\n")
    lines.append("| Cluster | Deployed | Total | Log |")
    lines.append("|---|---|---|---|")
    for c in summary["clusters"]:
        rel_log = os.path.relpath(c["log_path"], REPO_ROOT)
        lines.append(f"| {c['cluster']} | {c['deployed']} | {c['total_packages']} | `{rel_log}` |")
    lines.append("")
    lines.append("## Skipped packages by cluster\n")
    for c in summary["clusters"]:
        skipped = [e for e in c["log_entries"] if e["status"] != "DEPLOYED"]
        lines.append(f"### {c['cluster']}")
        if not skipped:
            lines.append("- (none -- all 28 packages deployed)")
        for e in skipped:
            lines.append(f"- `{e['package']}`: {e['status']} -- {e['reason']}")
        lines.append("")
    lines.append(f"## Figure\n")
    lines.append(f"See `{os.path.relpath(fig_path, REPO_ROOT)}`\n")
    with open(report_path, "w") as f:
        f.write("\n".join(lines))
    return report_path


def main():
    ecs = parse_all(EASYCONFIGS_DIR)
    graph = build_dependency_graph(ecs)
    order = topological_sort(graph)
    assert validate_topo_order(graph, order)

    run_output_dir = os.path.join(OUTPUT_DIR, "sim_run")
    os.makedirs(run_output_dir, exist_ok=True)
    summary = run_full_simulation(run_output_dir)

    fig_path = make_figure(graph, order)
    report_path = write_report(summary, fig_path)

    print(f"Parsed {summary['num_packages_parsed']} easyconfigs.")
    print("\nResolved install order:")
    for i, m in enumerate(summary["install_order"], 1):
        print(f"  {i:2d}. {m}")
    print("\nPer-cluster deployment counts:")
    for c in summary["clusters"]:
        print(f"  {c['cluster']:14s}: {c['deployed']:2d}/{c['total_packages']} deployed")
    print(f"\nReport written to: {report_path}")
    print(f"Figure written to: {fig_path}")


if __name__ == "__main__":
    main()
