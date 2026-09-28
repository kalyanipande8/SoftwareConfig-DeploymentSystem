#%Module1.0
##
## FFTW-3.3.10 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/FFTW-3.3.10.eb.
##
proc ModulesHelp { } {
    puts stderr {FFTW is a C subroutine library for computing the discrete Fourier transform in one or more dimensions.}
}

module-whatis {FFTW 3.3.10: https://www.fftw.org/}

set root /opt/software/FFTW/3.3.10

prereq GCC/12.3.0
prereq OpenMPI/4.1.5

conflict FFTW

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTFFTW $root
setenv EBVERSIONFFTW 3.3.10
