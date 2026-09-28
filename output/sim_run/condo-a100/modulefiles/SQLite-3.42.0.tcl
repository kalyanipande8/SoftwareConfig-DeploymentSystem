#%Module1.0
##
## SQLite-3.42.0 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/SQLite-3.42.0.eb.
##
proc ModulesHelp { } {
    puts stderr {SQLite: SQL Database Engine in a C Library}
}

module-whatis {SQLite 3.42.0: https://www.sqlite.org/}

set root /opt/software/SQLite/3.42.0

prereq GCCcore/12.3.0

conflict SQLite

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTSQLITE $root
setenv EBVERSIONSQLITE 3.42.0
