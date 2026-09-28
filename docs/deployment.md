# Deployment Guide

## Deployment model

Real EasyBuild deployments install software **in dependency order**: a
package cannot be built until every module it depends on (including its
toolchain) is already present. This repository computes that order for real,
from the actual `.eb` files, using `deploy_simulator/resolver.py`
(`topological_sort`, a from-scratch implementation of Kahn's algorithm).

The end-to-end flow, as implemented in `run_all.py`:

1. **Parse** every `.eb` file in `easyconfigs/` (`deploy_simulator/parser.py`)
   into a `name`, `version`, `toolchain`, `dependencies`, `moduleclass`.
2. **Build a dependency graph**: an edge from package P to dependency D for
   every entry in P's `dependencies` list, plus an edge to P's toolchain if
   that toolchain is itself one of the 28 packages (e.g. `foss/2023a`).
3. **Resolve** a single valid install order across all 28 packages with a
   topological sort, failing loudly if a cycle is ever introduced.
4. **Simulate deployment** across 4 clusters, walking the resolved order and,
   for each package, either "deploying" it (recording an install path and
   copying its real modulefile into a per-cluster output tree) or logging a
   concrete reason it was skipped on that cluster (missing GPU stack, no
   source mirror for its moduleclass, or a skipped dependency).
5. **Report**: `output/report.md` plus `output/figures/dependency_graph.png`.

## Rolling out a new package (real-world procedure)

1. Author the easyconfig: pick a toolchain, list real dependencies, put it in
   `easyconfigs/<Name>-<Version>.eb`.
2. Author (or, on a real cluster, let EasyBuild auto-generate) the matching
   modulefile in `modulefiles/<Name>-<Version>.tcl`, with `prereq` lines that
   match the easyconfig's `dependencies`.
3. Run `python3 run_all.py` locally -- this re-parses all easyconfigs, so a
   syntax error or a dependency on a package that doesn't exist yet is caught
   immediately (see `tests/test_pipeline.py` for the same checks as automated
   tests).
4. On a real cluster: `eb <Name>-<Version>.eb --robot` to build it and its
   unbuilt dependencies, then verify with `module load <Name>/<Version>` and
   a smoke test of the installed binary/library.
5. Roll out to each cluster independently, since (as modeled here) clusters
   can have different available hardware/toolchains -- a package that needs
   CUDA should never be marked "deployed" on a GPU-less cluster.

## Rollback

Because each install lives at its own versioned path
(`/opt/software/<Name>/<Version>`) and has its own modulefile, rollback is
just: stop advertising the new modulefile (or `module unload` it cluster-wide
via the module tool's admin controls) and leave the previous version's module
in place -- no in-place upgrades, so the previous version is never disturbed.

## Multi-cluster rollout order

When a package needs to reach all 4 clusters, deploy to a single canary
cluster first (this project uses `edge-devel`, the smallest), confirm the
smoke test passes, then proceed to the two GPU condos and finally
`genomics-cpu`. `output/report.md` records, per run, exactly which packages
succeeded on which cluster, so a partial rollout is always auditable.
