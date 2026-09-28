#%Module1.0
##
## zlib-1.2.13 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/zlib-1.2.13.eb.
##
proc ModulesHelp { } {
    puts stderr {zlib is designed to be a free, general-purpose, legally unencumbered, lossless data-compression library.}
}

module-whatis {zlib 1.2.13: https://www.zlib.net/}

set root /opt/software/zlib/1.2.13

prereq GCCcore/12.3.0

conflict zlib

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTZLIB $root
setenv EBVERSIONZLIB 1.2.13
