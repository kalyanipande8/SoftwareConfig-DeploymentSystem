#%Module1.0
##
## Boost-1.82.0 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/Boost-1.82.0.eb.
##
proc ModulesHelp { } {
    puts stderr {Boost provides free peer-reviewed portable C++ source libraries.}
}

module-whatis {Boost 1.82.0: https://www.boost.org/}

set root /opt/software/Boost/1.82.0

prereq GCC/12.3.0
prereq Python/3.11.3
prereq zlib/1.2.13

conflict Boost

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTBOOST $root
setenv EBVERSIONBOOST 1.82.0
