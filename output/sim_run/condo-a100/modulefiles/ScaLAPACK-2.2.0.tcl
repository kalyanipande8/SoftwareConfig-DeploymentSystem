#%Module1.0
##
## ScaLAPACK-2.2.0 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/ScaLAPACK-2.2.0.eb.
##
proc ModulesHelp { } {
    puts stderr {The ScaLAPACK library includes a subset of LAPACK routines redesigned for distributed memory MIMD parallel computers.}
}

module-whatis {ScaLAPACK 2.2.0: https://www.netlib.org/scalapack/}

set root /opt/software/ScaLAPACK/2.2.0

prereq GCC/12.3.0
prereq OpenMPI/4.1.5
prereq OpenBLAS/0.3.23

conflict ScaLAPACK

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTSCALAPACK $root
setenv EBVERSIONSCALAPACK 2.2.0
