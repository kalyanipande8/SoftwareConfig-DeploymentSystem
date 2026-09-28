#%Module1.0
##
## foss-2023a modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/foss-2023a.eb.
##
proc ModulesHelp { } {
    puts stderr {GNU Compiler Collection (GCC) based compiler toolchain, including OpenMPI for MPI support, OpenBLAS (BLAS and LAPACK support), FFTW and ScaLAPACK.}
}

module-whatis {foss 2023a: https://easybuild.readthedocs.io/en/latest/Common-toolchains.html}

set root /opt/software/foss/2023a

prereq GCC/12.3.0
prereq OpenMPI/4.1.5
prereq OpenBLAS/0.3.23
prereq FFTW/3.3.10
prereq ScaLAPACK/2.2.0

conflict foss

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTFOSS $root
setenv EBVERSIONFOSS 2023a
