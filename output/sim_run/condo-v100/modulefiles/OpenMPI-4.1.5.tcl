#%Module1.0
##
## OpenMPI-4.1.5 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/OpenMPI-4.1.5.eb.
##
proc ModulesHelp { } {
    puts stderr {The Open MPI Project is an open source Message Passing Interface implementation.}
}

module-whatis {OpenMPI 4.1.5: https://www.open-mpi.org/}

set root /opt/software/OpenMPI/4.1.5

prereq GCC/12.3.0
prereq zlib/1.2.13

conflict OpenMPI

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTOPENMPI $root
setenv EBVERSIONOPENMPI 4.1.5
