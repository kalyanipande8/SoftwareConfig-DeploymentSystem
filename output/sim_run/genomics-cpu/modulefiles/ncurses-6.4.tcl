#%Module1.0
##
## ncurses-6.4 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/ncurses-6.4.eb.
##
proc ModulesHelp { } {
    puts stderr {The Ncurses (new curses) library is a free software emulation of curses in System V Release 4.0.}
}

module-whatis {ncurses 6.4: https://www.gnu.org/software/ncurses/}

set root /opt/software/ncurses/6.4

prereq GCCcore/12.3.0

conflict ncurses

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTNCURSES $root
setenv EBVERSIONNCURSES 6.4
