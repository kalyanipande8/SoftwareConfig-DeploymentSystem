#%Module1.0
##
## CMake-3.26.3 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/CMake-3.26.3.eb.
##
proc ModulesHelp { } {
    puts stderr {CMake, the cross-platform, open-source build system.}
}

module-whatis {CMake 3.26.3: https://www.cmake.org/}

set root /opt/software/CMake/3.26.3

prereq GCCcore/12.3.0
prereq ncurses/6.4
prereq OpenSSL/1.1.1t

conflict CMake

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTCMAKE $root
setenv EBVERSIONCMAKE 3.26.3
