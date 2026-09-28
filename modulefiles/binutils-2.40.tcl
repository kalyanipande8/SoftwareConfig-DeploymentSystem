#%Module1.0
##
## binutils-2.40 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/binutils-2.40.eb.
##
proc ModulesHelp { } {
    puts stderr {binutils: GNU binary utilities}
}

module-whatis {binutils 2.40: https://www.gnu.org/software/binutils/}

set root /opt/software/binutils/2.40

prereq GCCcore/12.3.0

conflict binutils

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTBINUTILS $root
setenv EBVERSIONBINUTILS 2.40
