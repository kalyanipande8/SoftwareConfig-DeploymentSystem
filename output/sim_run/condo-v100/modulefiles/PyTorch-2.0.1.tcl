#%Module1.0
##
## PyTorch-2.0.1 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/PyTorch-2.0.1.eb.
##
proc ModulesHelp { } {
    puts stderr {PyTorch is an open source machine learning framework with GPU acceleration via CUDA.}
}

module-whatis {PyTorch 2.0.1: https://pytorch.org/}

set root /opt/software/PyTorch/2.0.1

prereq Python/3.11.3
prereq numpy/1.24.3
prereq CUDA/12.1.1
prereq cuDNN/8.9.2.26-CUDA-12.1.1
prereq foss/2023a

conflict PyTorch

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man
setenv CUDA_HOME $root

setenv EBROOTPYTORCH $root
setenv EBVERSIONPYTORCH 2.0.1
