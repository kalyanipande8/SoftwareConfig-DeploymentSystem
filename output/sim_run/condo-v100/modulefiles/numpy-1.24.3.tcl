#%Module1.0
##
## numpy-1.24.3 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/numpy-1.24.3.eb.
##
proc ModulesHelp { } {
    puts stderr {NumPy is the fundamental package for scientific computing with Python.}
}

module-whatis {numpy 1.24.3: https://numpy.org/}

set root /opt/software/numpy/1.24.3

prereq Python/3.11.3
prereq OpenBLAS/0.3.23
prereq foss/2023a

conflict numpy

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTNUMPY $root
setenv EBVERSIONNUMPY 1.24.3
