#%Module1.0
##
## GCCcore-12.3.0 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/GCCcore-12.3.0.eb.
##
proc ModulesHelp { } {
    puts stderr {The GNU Compiler Collection includes front ends for C, C++, Objective-C, Fortran, Java, and Ada, as well as libraries for these languages.}
}

module-whatis {GCCcore 12.3.0: https://gcc.gnu.org/}

set root /opt/software/GCCcore/12.3.0

conflict GCCcore

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTGCCCORE $root
setenv EBVERSIONGCCCORE 12.3.0
