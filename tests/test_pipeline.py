import os
import sys
import tempfile

import pytest

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(REPO_ROOT, "deploy_simulator"))

from parser import parse_all, build_dependency_graph, parse_easyconfig_file, EasyconfigParseError  # noqa: E402
from resolver import topological_sort, validate_topo_order, CycleDetectedError  # noqa: E402
from simulate_deployment import run_full_simulation, CLUSTERS  # noqa: E402

EASYCONFIGS_DIR = os.path.join(REPO_ROOT, "easyconfigs")


def test_all_28_easyconfigs_parse_without_error():
    ecs = parse_all(EASYCONFIGS_DIR)
    assert len(ecs) == 28
    for modname, ec in ecs.items():
        assert ec.name
        assert ec.version
        assert ec.moduleclass
        assert ec.homepage.startswith("http")


def test_every_dependency_reference_resolves_to_a_real_package():
    ecs = parse_all(EASYCONFIGS_DIR)
    for modname, ec in ecs.items():
        for dep_name, dep_ver in ec.dependencies:
            dep_mod = f"{dep_name}/{dep_ver}"
            assert dep_mod in ecs, f"{modname} depends on unknown package {dep_mod}"


def test_dependency_resolver_produces_valid_topological_order():
    ecs = parse_all(EASYCONFIGS_DIR)
    graph = build_dependency_graph(ecs)
    order = topological_sort(graph)
    assert len(order) == len(graph)
    # Real, computed check: every dependency must appear before the package
    # that needs it, for every single edge in the graph.
    assert validate_topo_order(graph, order)
    index = {m: i for i, m in enumerate(order)}
    for modname, deps in graph.items():
        for dep in deps:
            assert index[dep] < index[modname], (
                f"{dep} should be installed before {modname} but isn't"
            )


def test_example_chain_numpy_depends_on_python_and_openblas_before_it():
    ecs = parse_all(EASYCONFIGS_DIR)
    graph = build_dependency_graph(ecs)
    order = topological_sort(graph)
    index = {m: i for i, m in enumerate(order)}
    assert index["Python/3.11.3"] < index["numpy/1.24.3"]
    assert index["OpenBLAS/0.3.23"] < index["numpy/1.24.3"]
    assert index["GCC/12.3.0"] < index["OpenBLAS/0.3.23"]


def test_circular_dependency_is_detected_and_rejected():
    # Inject a deliberate cycle: A -> B -> C -> A, unrelated to the real 28.
    cyclic_graph = {
        "PkgA/1.0": ["PkgB/1.0"],
        "PkgB/1.0": ["PkgC/1.0"],
        "PkgC/1.0": ["PkgA/1.0"],
    }
    with pytest.raises(CycleDetectedError) as excinfo:
        topological_sort(cyclic_graph)
    # The resolver should genuinely identify the cyclic nodes, not just fail.
    assert set(excinfo.value.remaining_nodes) == {"PkgA/1.0", "PkgB/1.0", "PkgC/1.0"}


def test_malformed_easyconfig_raises_parse_error(tmp_path):
    bad_file = tmp_path / "Broken-1.0.eb"
    bad_file.write_text("name = 'Broken'\nversion = '1.0'\n this is not valid python (((\n")
    with pytest.raises(EasyconfigParseError):
        parse_easyconfig_file(str(bad_file))


def test_easyconfig_missing_required_field_raises_parse_error(tmp_path):
    bad_file = tmp_path / "Incomplete-1.0.eb"
    bad_file.write_text("name = 'Incomplete'\nversion = '1.0'\n")
    with pytest.raises(EasyconfigParseError):
        parse_easyconfig_file(str(bad_file))


def test_cluster_deployment_simulation_is_internally_consistent():
    with tempfile.TemporaryDirectory() as tmp:
        summary = run_full_simulation(tmp)
        assert summary["num_packages_parsed"] == 28
        assert len(summary["clusters"]) == 4

        for cluster_result in summary["clusters"]:
            entries = cluster_result["log_entries"]
            assert len(entries) == 28
            deployed = [e for e in entries if e["status"] == "DEPLOYED"]
            assert len(deployed) == cluster_result["deployed"]
            assert cluster_result["deployed"] + cluster_result["skipped"] == 28

            # Every DEPLOYED entry must have a real install path + an actual
            # modulefile that was written to disk.
            for e in deployed:
                assert e["install_path"]
                assert e["modulefile"]
                assert os.path.isfile(e["modulefile"])

            # Every non-deployed entry must carry a real, non-empty reason.
            for e in entries:
                if e["status"] != "DEPLOYED":
                    assert e["reason"]


def test_gpu_clusters_deploy_more_than_cpu_only_clusters():
    with tempfile.TemporaryDirectory() as tmp:
        summary = run_full_simulation(tmp)
        by_name = {c["cluster"]: c["deployed"] for c in summary["clusters"]}
        assert by_name["condo-a100"] == 28
        assert by_name["condo-v100"] == 28
        # genomics-cpu lacks GPUs -> CUDA/cuDNN/PyTorch/TensorFlow (4 pkgs) skipped
        assert by_name["genomics-cpu"] == 24
        # edge-devel lacks GPUs AND bio-domain mirror -> also loses
        # SAMtools/BLAST+/GROMACS
        assert by_name["edge-devel"] < by_name["genomics-cpu"]


def test_four_clusters_configured_with_expected_names():
    names = {c.name for c in CLUSTERS}
    assert names == {"condo-a100", "condo-v100", "genomics-cpu", "edge-devel"}
