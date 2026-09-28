#%Module1.0
##
## R-4.3.1 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/R-4.3.1.eb.
##
proc ModulesHelp { } {
    puts stderr {R is a free software environment for statistical computing and graphics.}
}

module-whatis {R 4.3.1: https://www.r-project.org/}

set root /opt/software/R/4.3.1

prereq GCC/12.3.0
prereq OpenBLAS/0.3.23
prereq zlib/1.2.13
prereq ncurses/6.4
prereq bzip2/1.0.8
prereq SQLite/3.42.0

conflict R

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTR $root
setenv EBVERSIONR 4.3.1
