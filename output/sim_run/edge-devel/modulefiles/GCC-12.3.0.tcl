#%Module1.0
##
## GCC-12.3.0 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/GCC-12.3.0.eb.
##
proc ModulesHelp { } {
    puts stderr {The GNU Compiler Collection full toolchain build (C, C++, Fortran) built on top of GCCcore, with binutils.}
}

module-whatis {GCC 12.3.0: https://gcc.gnu.org/}

set root /opt/software/GCC/12.3.0

prereq GCCcore/12.3.0
prereq binutils/2.40

conflict GCC

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTGCC $root
setenv EBVERSIONGCC 12.3.0
