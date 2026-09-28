#%Module1.0
##
## cuDNN-8.9.2.26-CUDA-12.1.1 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/cuDNN-8.9.2.26-CUDA-12.1.1.eb.
##
proc ModulesHelp { } {
    puts stderr {The NVIDIA CUDA Deep Neural Network library (cuDNN) is a GPU-accelerated library of primitives for deep neural networks.}
}

module-whatis {cuDNN 8.9.2.26-CUDA-12.1.1: https://developer.nvidia.com/cudnn}

set root /opt/software/cuDNN/8.9.2.26-CUDA-12.1.1

prereq GCCcore/12.3.0
prereq CUDA/12.1.1

conflict cuDNN

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man
setenv CUDA_HOME $root

setenv EBROOTCUDNN $root
setenv EBVERSIONCUDNN 8.9.2.26-CUDA-12.1.1
