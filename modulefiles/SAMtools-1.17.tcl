#%Module1.0
##
## SAMtools-1.17 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/SAMtools-1.17.eb.
##
proc ModulesHelp { } {
    puts stderr {SAM Tools provide various utilities for manipulating alignments in the SAM/BAM/CRAM format.}
}

module-whatis {SAMtools 1.17: https://www.htslib.org/}

set root /opt/software/SAMtools/1.17

prereq GCC/12.3.0
prereq ncurses/6.4
prereq bzip2/1.0.8
prereq zlib/1.2.13

conflict SAMtools

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTSAMTOOLS $root
setenv EBVERSIONSAMTOOLS 1.17
