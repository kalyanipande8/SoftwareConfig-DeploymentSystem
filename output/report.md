# Deployment Simulation Report

Packages parsed: **28**

## Resolved install order

1. `GCCcore/12.3.0`
2. `CUDA/12.1.1`
3. `OpenSSL/1.1.1t`
4. `SQLite/3.42.0`
5. `binutils/2.40`
6. `bzip2/1.0.8`
7. `libffi/3.4.4`
8. `ncurses/6.4`
9. `zlib/1.2.13`
10. `cuDNN/8.9.2.26-CUDA-12.1.1`
11. `GCC/12.3.0`
12. `CMake/3.26.3`
13. `Python/3.11.3`
14. `OpenBLAS/0.3.23`
15. `OpenMPI/4.1.5`
16. `SAMtools/1.17`
17. `Boost/1.82.0`
18. `BLAST+/2.14.0`
19. `FFTW/3.3.10`
20. `HDF5/1.14.0`
21. `ScaLAPACK/2.2.0`
22. `foss/2023a`
23. `GROMACS/2023.2`
24. `R/4.3.1`
25. `numpy/1.24.3`
26. `PyTorch/2.0.1`
27. `SciPy-bundle/2023.05`
28. `TensorFlow/2.13.0`

## Per-cluster deployment results

| Cluster | Deployed | Total | Log |
|---|---|---|---|
| condo-a100 | 28 | 28 | `output/sim_run/condo-a100/deployment_log.csv` |
| condo-v100 | 28 | 28 | `output/sim_run/condo-v100/deployment_log.csv` |
| genomics-cpu | 24 | 28 | `output/sim_run/genomics-cpu/deployment_log.csv` |
| edge-devel | 21 | 28 | `output/sim_run/edge-devel/deployment_log.csv` |

## Skipped packages by cluster

### condo-a100
- (none -- all 28 packages deployed)

### condo-v100
- (none -- all 28 packages deployed)

### genomics-cpu
- `CUDA/12.1.1`: SKIPPED -- requires GPU/CUDA driver stack, not available on cluster 'genomics-cpu'
- `cuDNN/8.9.2.26-CUDA-12.1.1`: SKIPPED -- requires GPU/CUDA driver stack, not available on cluster 'genomics-cpu'
- `PyTorch/2.0.1`: SKIPPED -- requires GPU/CUDA driver stack, not available on cluster 'genomics-cpu'
- `TensorFlow/2.13.0`: SKIPPED -- requires GPU/CUDA driver stack, not available on cluster 'genomics-cpu'

### edge-devel
- `CUDA/12.1.1`: SKIPPED -- requires GPU/CUDA driver stack, not available on cluster 'edge-devel'
- `cuDNN/8.9.2.26-CUDA-12.1.1`: SKIPPED -- requires GPU/CUDA driver stack, not available on cluster 'edge-devel'
- `SAMtools/1.17`: SKIPPED -- moduleclass 'bio' has no source mirror configured on cluster 'edge-devel'
- `BLAST+/2.14.0`: SKIPPED -- moduleclass 'bio' has no source mirror configured on cluster 'edge-devel'
- `GROMACS/2023.2`: SKIPPED -- moduleclass 'bio' has no source mirror configured on cluster 'edge-devel'
- `PyTorch/2.0.1`: SKIPPED -- requires GPU/CUDA driver stack, not available on cluster 'edge-devel'
- `TensorFlow/2.13.0`: SKIPPED -- requires GPU/CUDA driver stack, not available on cluster 'edge-devel'

## Figure

See `output/figures/dependency_graph.png`
