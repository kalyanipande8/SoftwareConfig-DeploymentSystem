# Troubleshooting Guide

Real, common EasyBuild / Environment Modules issues and their fixes,
including the ones this project's design specifically guards against.

## 1. "Toolchain mismatch" / `EasyBuildError: No easyconfig found`

**Symptom**: `eb SomePkg-1.0.eb --robot` fails with something like
`No module named 'SomeToolchain'` or refuses to resolve a dependency.

**Cause**: The easyconfig declares a `toolchain` (e.g. `foss-2023a`) that
doesn't match the toolchain any of its listed `dependencies` were built with.
EasyBuild will not silently mix a `GCC-12.3.0`-built library into a
`foss-2022b` build.

**Fix**: Make sure every dependency in the `dependencies` list was itself
built with a toolchain that is compatible with (a subset of, or identical to)
the package's own `toolchain`. In this repo, `deploy_simulator/parser.py`
records the declared toolchain and dependencies verbatim -- cross-check them
by eye, or add an assertion in `tests/test_pipeline.py` that flags toolchain
mismatches if you introduce new packages.

## 2. "Missing prerequisite module" (`prereq` failure)

**Symptom**: `module load numpy/1.24.3` fails with:
```
ERROR: 130: Module 'numpy/1.24.3' depends on one or more modules that must be loaded first: OpenBLAS/0.3.23
```

**Cause**: The modulefile's `prereq` lines (see `modulefiles/numpy-1.24.3.tcl`)
require `Python/3.11.3`, `OpenBLAS/0.3.23`, and `foss/2023a` to already be
loaded in the user's environment. Loading `numpy` directly, without its
prerequisites, trips this.

**Fix**: Load dependencies first (`module load Python/3.11.3 OpenBLAS/0.3.23
foss/2023a`), or -- on clusters using Lmod instead of Tcl Environment
Modules -- convert to Lmod-style automatic prerequisite loading. In this
project, `deploy_simulator/resolver.py`'s topological order guarantees every
dependency is *installed* before its dependents; it does not auto-load
modules for you at runtime, so end users still need the `prereq` chain or a
wrapper/module-collection.

## 3. Conflicting module versions

**Symptom**:
```
ERROR: 150: Module 'GCC/12.3.0' conflicts with the currently loaded module(s) 'GCC/11.3.0'
```

**Cause**: Two versions of the same package/toolchain were loaded at once.
Every modulefile in this repo includes a `conflict <name>` line (see any file
in `modulefiles/`) specifically to make this fail loudly rather than produce
a broken, mixed-ABI environment.

**Fix**: `module purge` (or `module unload GCC/11.3.0`) before loading the
new version. When switching toolchain generations for a whole environment,
it's safest to `module purge` and reload the full stack for the target
toolchain rather than swapping individual modules.

## 4. Circular dependency introduced by a new easyconfig

**Symptom**: `python3 run_all.py` raises `CycleDetectedError: Circular
dependency detected among: [...]`.

**Cause**: A newly-added easyconfig's `dependencies` list (directly or
transitively) points back at a package that depends on it. This is caught for
real by `deploy_simulator/resolver.py::topological_sort`, which uses Kahn's
algorithm and reports precisely which nodes never became "ready" -- i.e. the
cyclic subset -- rather than just crashing.

**Fix**: Break the cycle by removing the incorrect dependency edge, or by
introducing an intermediate, lower-level package that both can depend on
instead of depending on each other.
`tests/test_pipeline.py::test_circular_dependency_is_detected_and_rejected`
exercises this against a deliberately-injected 3-node cycle as a permanent
regression check.

## 5. GPU package fails to "deploy" on a CPU-only cluster

**Symptom**: In `output/sim_run/genomics-cpu/deployment_log.csv`,
`CUDA/12.1.1`, `cuDNN/8.9.2.26-CUDA-12.1.1`, `PyTorch/2.0.1`, and
`TensorFlow/2.13.0` all show `status=SKIPPED`.

**Cause**: This is expected, correct behavior, not a bug -- the
`genomics-cpu` cluster has `has_gpu=False` in
`deploy_simulator/simulate_deployment.py::CLUSTERS`, matching the real-world
fact that those nodes have no NVIDIA driver/CUDA stack. Real EasyBuild builds
of CUDA-dependent packages would fail outright on such hardware.

**Fix**: Nothing to fix -- confirm the `reason` column in the deployment log
correctly attributes the skip to "requires GPU/CUDA driver stack." If a
package is wrongly marked GPU-only, correct its entry in
`GPU_PACKAGE_NAMES` in `simulate_deployment.py`.

## 6. Easyconfig fails to parse (`EasyconfigParseError`)

**Symptom**: `python3 run_all.py` (or `pytest`) raises
`EasyconfigParseError: <file>: invalid Python/easyconfig syntax` or
`missing required field(s)`.

**Cause**: `deploy_simulator/parser.py` parses each `.eb` file with Python's
`ast` module and requires `name`, `version`, `homepage`, `description`, and
`moduleclass` to be present as literal top-level assignments, and
`dependencies` entries to be 2+ element tuples/lists.

**Fix**: Check the offending file for a typo (unbalanced quote/bracket,
non-literal value such as a function call in a field EasyBuild would
normally template, or a missing required field) and re-run
`python3 -m pytest -q tests/test_pipeline.py::test_all_28_easyconfigs_parse_without_error`.
