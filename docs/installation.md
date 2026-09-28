# Installation Guide

This document describes how these 28 packages would be installed on a real
HPC cluster using EasyBuild, and how to run the local validation/simulation
layer in this repository.

## 1. Installing on a real cluster (reference procedure)

These steps describe correct EasyBuild practice; they are **not** executed by
this repository (see `README.md` for the real-vs-simulated boundary).

```bash
# One-time: install EasyBuild itself into a bootstrap prefix
python3 -m pip install --user easybuild

# Point EasyBuild at a shared install/module tree
export EASYBUILD_PREFIX=/opt/software/easybuild
export EASYBUILD_MODULES_TOOL=EnvironmentModulesC
export EASYBUILD_ROBOT_PATHS=$PWD/easyconfigs

# Install a single package (EasyBuild resolves + builds its dependency
# chain automatically using --robot)
eb GCCcore-12.3.0.eb --robot
eb GCC-12.3.0.eb --robot
eb OpenMPI-4.1.5.eb --robot
...
eb TensorFlow-2.13.0.eb --robot
```

In production we install packages in **dependency order** so that every
prerequisite module is already present before its dependents are built. That
order is exactly what `deploy_simulator/resolver.py` computes for the 28
packages in this repo (see `output/report.md` for the real, computed order).

## 2. Installing modulefiles

Each easyconfig has a matching modulefile in `modulefiles/*.tcl`. On a real
cluster, EasyBuild writes these automatically into
`$EASYBUILD_PREFIX/modules/all/<Name>/<Version>`. Here they are
hand-authored to mirror what EasyBuild would generate, so they can be
reviewed without a live EasyBuild install:

```bash
export MODULEPATH=/opt/software/easybuild/modules/all:$MODULEPATH
module avail
module load GCC/12.3.0 OpenMPI/4.1.5 numpy/1.24.3
```

## 3. Running the local validation/simulation pipeline in this repo

No EasyBuild or Modules installation is required to run the pipeline in this
repository -- it is pure Python 3.9+ with only `pytest` (for tests) and
`matplotlib` (optional, for the dependency-graph figure) as dependencies.

```bash
cd SoftwareConfig-DeploymentSystem
python3 -m pip install matplotlib pytest   # if not already available
python3 run_all.py                          # parse -> resolve -> simulate -> report
python3 -m pytest -q                        # run the test suite
```

`run_all.py` writes:
- `output/report.md` -- the resolved install order and per-cluster deployment counts
- `output/figures/dependency_graph.png` -- a layered visualization of the dependency graph
- `output/sim_run/<cluster>/deployment_log.csv` -- a per-cluster deployment log
- `output/sim_run/<cluster>/modulefiles/*.tcl` -- copies of the modulefiles "deployed" on that cluster

## 4. Troubleshooting installation issues

See `docs/troubleshooting.md` for the most common EasyBuild/Modules
installation failures and their fixes.
