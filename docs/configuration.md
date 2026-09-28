# Configuration Guide

## EasyBuild configuration

Key EasyBuild environment variables used across the 4 simulated clusters in
this project (as they would be set in a real deployment, e.g. in
`/etc/profile.d/easybuild.sh` or a cluster's module-environment init script):

| Variable | Purpose | Example |
|---|---|---|
| `EASYBUILD_PREFIX` | Root of the install + module tree | `/opt/software/easybuild` |
| `EASYBUILD_BUILDPATH` | Scratch space for in-progress builds | `/scratch/$USER/easybuild-build` |
| `EASYBUILD_SOURCEPATH` | Where source tarballs are cached/mirrored | `/opt/software/sources` |
| `EASYBUILD_ROBOT_PATHS` | Search path(s) for easyconfigs (this repo's `easyconfigs/`) | `$PWD/easyconfigs` |
| `EASYBUILD_MODULES_TOOL` | Which modules backend to generate for | `EnvironmentModulesC` or `Lmod` |
| `EASYBUILD_OPTARCH` | CPU-architecture-specific optimization flags | `Intel:march=skylake-avx512` |

## Toolchain configuration

This project's 28 packages are built against two toolchain families, matching
real EasyBuild convention:

- **`GCCcore-12.3.0`** -- the minimal compiler-only toolchain, used for
  packages that don't need MPI or optimized math libraries (e.g. `zlib`,
  `Python`, `CMake`).
- **`GCC-12.3.0`** -- `GCCcore` plus `binutils`, the base for anything that
  needs a "full" compiler but not MPI (e.g. `OpenBLAS`, `Boost`).
- **`gompi-2023a`** -- `GCC-12.3.0` + `OpenMPI-4.1.5`, for MPI-parallel
  libraries (e.g. `FFTW`, `HDF5`, `BLAST+`).
- **`foss-2023a`** -- the "full" toolchain: `gompi` + `OpenBLAS` +
  `ScaLAPACK`, used by the highest-level scientific packages (`numpy`,
  `SciPy-bundle`, `GROMACS`, `PyTorch`, `TensorFlow`, `R`).

Using a shared, versioned toolchain (rather than letting each package pick
its own compiler/MPI/BLAS) is what makes the dependency graph in
`easyconfigs/` resolvable and avoids ABI mismatches at link time.

## Per-cluster configuration

`deploy_simulator/simulate_deployment.py` defines 4 clusters with genuinely
different available configuration, mirroring a real multi-cluster HPC estate:

| Cluster | GPUs | Notes |
|---|---|---|
| `condo-a100` | Yes (A100) | Full toolchain + CUDA 12.1 stack |
| `condo-v100` | Yes (V100) | Full toolchain + CUDA 12.1 stack |
| `genomics-cpu` | No | CPU-only nodes; CUDA/cuDNN/PyTorch/TensorFlow are not installable |
| `edge-devel` | No | CPU-only, smaller devel cluster; also has no bio-domain source mirror configured, so `SAMtools`/`BLAST+`/`GROMACS` are skipped |

Cluster definitions are plain Python `Cluster` dataclass instances in that
file -- adding a 5th cluster means adding one more entry to `CLUSTERS`.

## Modulefile configuration conventions

Every modulefile in `modulefiles/` follows the same structure:

- `module-whatis` -- a one-line description for `module whatis <name>`
- `set root ...` -- the install prefix for that package/version
- `prereq <dep>/<version>` -- one line per real dependency declared in the
  matching `.eb` file (loading this module without its prereqs loaded first
  will raise a "prereq" error under real Environment Modules)
- `conflict <name>` -- prevents two versions of the same package from being
  loaded simultaneously
- `prepend-path PATH|LD_LIBRARY_PATH|LIBRARY_PATH|CPATH|MANPATH` -- standard
  environment wiring
- `setenv EBROOT<NAME> / EBVERSION<NAME>` -- EasyBuild-style environment
  variables that downstream easyconfigs/modules can reference
