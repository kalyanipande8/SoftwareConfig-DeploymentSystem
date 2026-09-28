#%Module1.0
##
## CUDA-12.1.1 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/CUDA-12.1.1.eb.
##
proc ModulesHelp { } {
    puts stderr {CUDA is a parallel computing platform and programming model for general computing on GPUs.}
}

module-whatis {CUDA 12.1.1: https://developer.nvidia.com/cuda-toolkit}

set root /opt/software/CUDA/12.1.1

prereq GCCcore/12.3.0

conflict CUDA

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man
setenv CUDA_HOME $root

setenv EBROOTCUDA $root
setenv EBVERSIONCUDA 12.1.1
