#%Module1.0
##
## GROMACS-2023.2 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/GROMACS-2023.2.eb.
##
proc ModulesHelp { } {
    puts stderr {GROMACS is a versatile package for molecular dynamics simulation.}
}

module-whatis {GROMACS 2023.2: https://www.gromacs.org/}

set root /opt/software/GROMACS/2023.2

prereq GCC/12.3.0
prereq OpenMPI/4.1.5
prereq FFTW/3.3.10
prereq foss/2023a

conflict GROMACS

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTGROMACS $root
setenv EBVERSIONGROMACS 2023.2
