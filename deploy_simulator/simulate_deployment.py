"""Runs the parser + resolver across 4 simulated HPC clusters and produces a
real per-cluster deployment log plus summary stats.

"Deployed" here means, honestly: the package's easyconfig was parsed, its
place in the dependency-resolved install order was computed, its
prerequisites were confirmed available on that cluster, and a modulefile for
it exists (we read the real generated .tcl file and copy it into a per-run,
per-cluster output tree) -- NOT that a real EasyBuild `eb` install ran on
real hardware. See README.md for the explicit real-vs-simulated boundary.

Cluster variation is real and consequential, not cosmetic:
  - "condo-a100"   : full foss/gompi toolchains + CUDA 12.1 GPUs available.
  - "condo-v100"   : full toolchains + older-but-compatible CUDA 12.1 GPUs.
  - "genomics-cpu" : CPU-only nodes -- no CUDA/cuDNN driver stack installed,
                     so CUDA and everything that (transitively) depends on it
                     (cuDNN, PyTorch, TensorFlow) is skipped with a logged
                     reason.
  - "edge-devel"   : a smaller devel/test cluster that also lacks GPUs AND
                     has not licensed/mirrored the bio-domain sources
                     (SAMtools, BLAST+, GROMACS are skipped -- no source
                     mirror configured for that moduleclass on this cluster).
"""
from __future__ import annotations

import os
import shutil
from dataclasses import dataclass, field

from parser import parse_all, build_dependency_graph, Easyconfig
from resolver import topological_sort, validate_topo_order, CycleDetectedError

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EASYCONFIGS_DIR = os.path.join(REPO_ROOT, "easyconfigs")
MODULEFILES_DIR = os.path.join(REPO_ROOT, "modulefiles")


@dataclass
class Cluster:
    name: str
    has_gpu: bool
    excluded_moduleclasses: set = field(default_factory=set)
    install_prefix: str = "/opt/software"


CLUSTERS = [
    Cluster(name="condo-a100", has_gpu=True),
    Cluster(name="condo-v100", has_gpu=True),
    Cluster(name="genomics-cpu", has_gpu=False),
    Cluster(name="edge-devel", has_gpu=False, excluded_moduleclasses={"bio"}),
]

GPU_PACKAGE_NAMES = {"CUDA", "cuDNN", "PyTorch", "TensorFlow"}


def _skip_reason(ec: Easyconfig, cluster: Cluster, skipped_so_far: set) -> str | None:
    if ec.name in GPU_PACKAGE_NAMES and not cluster.has_gpu:
        return f"requires GPU/CUDA driver stack, not available on cluster '{cluster.name}'"
    if ec.moduleclass in cluster.excluded_moduleclasses:
        return f"moduleclass '{ec.moduleclass}' has no source mirror configured on cluster '{cluster.name}'"
    for dep_name, dep_ver in ec.dependencies:
        if f"{dep_name}/{dep_ver}" in skipped_so_far:
            return f"dependency {dep_name}/{dep_ver} was skipped on cluster '{cluster.name}'"
    return None


def simulate_cluster(cluster: Cluster, ecs: dict, order: list[str], run_output_dir: str) -> dict:
    cluster_dir = os.path.join(run_output_dir, cluster.name)
    modules_out = os.path.join(cluster_dir, "modulefiles")
    os.makedirs(modules_out, exist_ok=True)

    log_entries = []
    skipped_modnames: set = set()
    deployed_count = 0

    for idx, modname in enumerate(order, start=1):
        ec = ecs[modname]
        reason = _skip_reason(ec, cluster, skipped_modnames)
        if reason is not None:
            skipped_modnames.add(modname)
            log_entries.append({
                "order": idx,
                "package": modname,
                "status": "SKIPPED",
                "reason": reason,
                "install_path": None,
                "modulefile": None,
            })
            continue

        install_path = f"{cluster.install_prefix}/{ec.name}/{ec.version}"
        src_modulefile = os.path.join(MODULEFILES_DIR, f"{ec.name}-{ec.version}.tcl")
        if not os.path.isfile(src_modulefile):
            skipped_modnames.add(modname)
            log_entries.append({
                "order": idx,
                "package": modname,
                "status": "FAILED",
                "reason": f"no modulefile found at {src_modulefile}",
                "install_path": None,
                "modulefile": None,
            })
            continue

        dest_modulefile = os.path.join(modules_out, f"{ec.name}-{ec.version}.tcl")
        shutil.copyfile(src_modulefile, dest_modulefile)
        deployed_count += 1
        log_entries.append({
            "order": idx,
            "package": modname,
            "status": "DEPLOYED",
            "reason": None,
            "install_path": install_path,
            "modulefile": dest_modulefile,
        })

    log_path = os.path.join(cluster_dir, "deployment_log.csv")
    with open(log_path, "w") as f:
        f.write("order,package,status,install_path,modulefile,reason\n")
        for e in log_entries:
            f.write(",".join([
                str(e["order"]), e["package"], e["status"],
                e["install_path"] or "", e["modulefile"] or "",
                (e["reason"] or "").replace(",", ";"),
            ]) + "\n")

    return {
        "cluster": cluster.name,
        "total_packages": len(order),
        "deployed": deployed_count,
        "skipped": len(order) - deployed_count,
        "log_path": log_path,
        "log_entries": log_entries,
    }


def run_full_simulation(run_output_dir: str) -> dict:
    ecs = parse_all(EASYCONFIGS_DIR)
    graph = build_dependency_graph(ecs)
    order = topological_sort(graph)  # raises CycleDetectedError if cyclic
    assert validate_topo_order(graph, order), "resolver produced an invalid order"

    results = []
    for cluster in CLUSTERS:
        results.append(simulate_cluster(cluster, ecs, order, run_output_dir))

    return {
        "num_packages_parsed": len(ecs),
        "install_order": order,
        "clusters": results,
    }


if __name__ == "__main__":
    out = os.path.join(REPO_ROOT, "output", "sim_run")
    os.makedirs(out, exist_ok=True)
    summary = run_full_simulation(out)
    print(f"Parsed {summary['num_packages_parsed']} packages.")
    print("Resolved install order:")
    for i, m in enumerate(summary["install_order"], 1):
        print(f"  {i:2d}. {m}")
    print()
    for c in summary["clusters"]:
        print(f"Cluster {c['cluster']}: {c['deployed']}/{c['total_packages']} deployed, log at {c['log_path']}")
