#%Module1.0
##
## libffi-3.4.4 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/libffi-3.4.4.eb.
##
proc ModulesHelp { } {
    puts stderr {The libffi library provides a portable, high level programming interface to various calling conventions.}
}

module-whatis {libffi 3.4.4: https://sourceware.org/libffi/}

set root /opt/software/libffi/3.4.4

prereq GCCcore/12.3.0

conflict libffi

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTLIBFFI $root
setenv EBVERSIONLIBFFI 3.4.4
