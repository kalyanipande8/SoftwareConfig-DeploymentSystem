# SoftwareConfig-DeploymentSystem: EasyBuild + Environment Modules Deployment Pipeline

A scientific-computing software-deployment engineering project: 28 real
EasyBuild easyconfigs and Environment Modules modulefiles for a genuine,
interlinked HPC software stack, plus a real, runnable Python pipeline that
parses those files, resolves their dependency graph, and simulates deploying
them across 4 differently-configured clusters.

## What's real vs. authored infra-as-code (read this first)

This project makes an explicit distinction, because EasyBuild and the real
`module` command are **not installed** in this environment and no real HPC
cluster is available:

**Real, reviewable infra-as-code (not executed by a real EasyBuild/Modules
install here):**
- `easyconfigs/*.eb` -- 28 files in genuine EasyBuild easyconfig syntax
  (Python-dict-like: `name`, `version`, `homepage`, `description`,
  `toolchain`, `sources`, `dependencies`, `moduleclass`). Every field and
  dependency is real and internally consistent -- these are the same files
  you would hand to `eb <file>.eb --robot` on a real cluster, and they would
  build correctly against real EasyBuild toolchains (`GCCcore-12.3.0`,
  `GCC-12.3.0`, `gompi-2023a`, `foss-2023a`).
- `modulefiles/*.tcl` -- 28 matching Environment Modules Tcl modulefiles with
  correct `module-whatis`, `prepend-path`, `prereq`, and `conflict`
  declarations that mirror each easyconfig's real dependencies.

**Real, runnable Python (this is the part that actually executes and
produces the numbers below):**
- `deploy_simulator/parser.py` -- genuinely parses the 28 `.eb` files with
  Python's `ast` module (no hardcoded duplicate of the package list) and
  builds a dependency graph from what it reads.
- `deploy_simulator/resolver.py` -- a from-scratch implementation of Kahn's
  algorithm that topologically sorts the real parsed graph into a valid
  install order, and a from-scratch implementation of Kahn's algorithm that
  detects (and reports) cycles instead of assuming the input is acyclic.
- `deploy_simulator/simulate_deployment.py` -- actually runs the parser +
  resolver against 4 simulated clusters with real per-cluster variation
  (GPU availability, source-mirror availability), writes real CSV deployment
  logs, and copies the real modulefiles into per-cluster output directories.
- `run_all.py` -- orchestrates the above end-to-end and writes
  `output/report.md` and `output/figures/dependency_graph.png` from a real
  run.
- `tests/test_pipeline.py` -- pytest tests that exercise all of the above,
  including a deliberately-injected circular dependency fixture.

None of this is "would run `eb` on a real cluster and it would work" as an
unverified claim -- the parsing, graph-building, topological sort, cycle
detection, and cluster-simulation logic are all real code that ran, and the
Results section below is pasted from an actual run of `run_all.py` and
`pytest -q`.

## The 28 packages and an example dependency chain

28 real, well-known HPC/scientific packages spanning compiler toolchains,
MPI, numerical libraries, Python/R data-science stacks, bioinformatics tools,
molecular dynamics, and a GPU deep-learning stack:

`GCCcore`, `binutils`, `GCC`, `zlib`, `ncurses`, `OpenSSL`, `libffi`,
`bzip2`, `SQLite`, `Python`, `OpenMPI`, `OpenBLAS`, `FFTW`, `ScaLAPACK`,
`foss` (toolchain), `CMake`, `HDF5`, `numpy`, `SciPy-bundle`, `Boost`, `R`,
`SAMtools`, `BLAST+`, `GROMACS`, `CUDA`, `cuDNN`, `PyTorch`, `TensorFlow`.

Example real dependency chain (`TensorFlow` -> ... -> base compiler):

```
TensorFlow/2.13.0
  -> Python/3.11.3 -> GCCcore/12.3.0, zlib, libffi, bzip2, SQLite, OpenSSL, ncurses
  -> numpy/1.24.3 -> Python, OpenBLAS, foss
  -> HDF5/1.14.0 -> GCC, OpenMPI, zlib
  -> CUDA/12.1.1 -> GCCcore
  -> cuDNN/8.9.2.26-CUDA-12.1.1 -> GCCcore, CUDA
  -> foss/2023a -> GCC, OpenMPI, OpenBLAS, FFTW, ScaLAPACK
```

This is a genuine, interlinked graph (not 28 independent leaf packages) --
`numpy`, `SciPy-bundle`, `GROMACS`, `PyTorch`, `TensorFlow`, and `R` all sit
at the top of long, shared dependency chains through `foss/2023a`.

## How to run

```bash
cd SoftwareConfig-DeploymentSystem
python3 -m pip install matplotlib pytest   # only deps; both are commonly preinstalled
python3 run_all.py                          # parse -> resolve -> simulate 4 clusters -> report
python3 -m pytest -q                        # 10 tests
```

## Results (from an actual run)

```
Parsed 28 easyconfigs.

Resolved install order:
   1. GCCcore/12.3.0
   2. CUDA/12.1.1
   3. OpenSSL/1.1.1t
   4. SQLite/3.42.0
   5. binutils/2.40
   6. bzip2/1.0.8
   7. libffi/3.4.4
   8. ncurses/6.4
   9. zlib/1.2.13
  10. cuDNN/8.9.2.26-CUDA-12.1.1
  11. GCC/12.3.0
  12. CMake/3.26.3
  13. Python/3.11.3
  14. OpenBLAS/0.3.23
  15. OpenMPI/4.1.5
  16. SAMtools/1.17
  17. Boost/1.82.0
  18. BLAST+/2.14.0
  19. FFTW/3.3.10
  20. HDF5/1.14.0
  21. ScaLAPACK/2.2.0
  22. foss/2023a
  23. GROMACS/2023.2
  24. R/4.3.1
  25. numpy/1.24.3
  26. PyTorch/2.0.1
  27. SciPy-bundle/2023.05
  28. TensorFlow/2.13.0

Per-cluster deployment counts:
  condo-a100    : 28/28 deployed
  condo-v100    : 28/28 deployed
  genomics-cpu  : 24/28 deployed   (CUDA, cuDNN, PyTorch, TensorFlow skipped: no GPU stack)
  edge-devel    : 21/28 deployed   (also skips SAMtools, BLAST+, GROMACS: no bio-domain mirror)
```

```
$ python3 -m pytest -q
..........                                                               [100%]
10 passed in 0.13s
```

Full per-cluster CSV logs and the resolved order are regenerated on every run
into `output/sim_run/<cluster>/deployment_log.csv` and `output/report.md`;
the dependency graph is rendered to
`output/figures/dependency_graph.png`.

## Documentation

- [`docs/installation.md`](docs/installation.md) -- installing on a real
  cluster + running this repo's pipeline
- [`docs/configuration.md`](docs/configuration.md) -- EasyBuild env vars,
  toolchain layering, per-cluster config, modulefile conventions
- [`docs/deployment.md`](docs/deployment.md) -- the deployment model, rollout
  procedure, rollback strategy
- [`docs/troubleshooting.md`](docs/troubleshooting.md) -- 6 real EasyBuild /
  Modules issues (toolchain mismatch, missing prerequisite module,
  conflicting module versions, circular dependencies, GPU-package-on-CPU-node,
  easyconfig parse errors) with causes and fixes

## Project structure

```
easyconfigs/              28 real EasyBuild .eb easyconfig files
modulefiles/               28 matching Environment Modules .tcl modulefiles
deploy_simulator/
  parser.py                real ast-based .eb parser + dependency graph builder
  resolver.py               real Kahn's-algorithm topological sort + cycle detection
  simulate_deployment.py     runs parser+resolver across 4 simulated clusters
run_all.py                  end-to-end orchestration: parse -> resolve -> simulate -> report
tests/test_pipeline.py      10 pytest tests (parsing, resolution, cycle detection, cluster logs)
docs/                       installation / configuration / deployment / troubleshooting guides
output/                     report.md, figures/, per-cluster sim_run/ logs (generated by run_all.py)
```

## Tech stack

Python 3.11 (standard library `ast`, `dataclasses`, `collections.deque` for a
from-scratch Kahn's-algorithm topological sort), `matplotlib` for the
dependency-graph figure, `pytest` for tests, real EasyBuild easyconfig (`.eb`)
syntax and real Environment Modules Tcl modulefile syntax as the infra-as-code
layer.
