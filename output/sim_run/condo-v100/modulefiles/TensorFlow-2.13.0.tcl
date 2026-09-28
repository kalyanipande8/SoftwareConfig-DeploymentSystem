#%Module1.0
##
## TensorFlow-2.13.0 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/TensorFlow-2.13.0.eb.
##
proc ModulesHelp { } {
    puts stderr {TensorFlow is an open source software library for numerical computation using data flow graphs.}
}

module-whatis {TensorFlow 2.13.0: https://www.tensorflow.org/}

set root /opt/software/TensorFlow/2.13.0

prereq Python/3.11.3
prereq numpy/1.24.3
prereq HDF5/1.14.0
prereq CUDA/12.1.1
prereq cuDNN/8.9.2.26-CUDA-12.1.1
prereq foss/2023a

conflict TensorFlow

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man
setenv CUDA_HOME $root

setenv EBROOTTENSORFLOW $root
setenv EBVERSIONTENSORFLOW 2.13.0
