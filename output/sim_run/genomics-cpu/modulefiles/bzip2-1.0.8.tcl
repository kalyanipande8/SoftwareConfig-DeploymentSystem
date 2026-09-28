#%Module1.0
##
## bzip2-1.0.8 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/bzip2-1.0.8.eb.
##
proc ModulesHelp { } {
    puts stderr {bzip2 is a freely available, patent free, high-quality data compressor.}
}

module-whatis {bzip2 1.0.8: https://sourceware.org/bzip2/}

set root /opt/software/bzip2/1.0.8

prereq GCCcore/12.3.0

conflict bzip2

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTBZIP2 $root
setenv EBVERSIONBZIP2 1.0.8
