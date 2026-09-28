#%Module1.0
##
## OpenBLAS-0.3.23 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/OpenBLAS-0.3.23.eb.
##
proc ModulesHelp { } {
    puts stderr {OpenBLAS is an optimized BLAS library based on GotoBLAS2.}
}

module-whatis {OpenBLAS 0.3.23: https://www.openblas.net/}

set root /opt/software/OpenBLAS/0.3.23

prereq GCC/12.3.0

conflict OpenBLAS

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTOPENBLAS $root
setenv EBVERSIONOPENBLAS 0.3.23
