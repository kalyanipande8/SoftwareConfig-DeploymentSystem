#%Module1.0
##
## Python-3.11.3 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/Python-3.11.3.eb.
##
proc ModulesHelp { } {
    puts stderr {Python is a programming language that lets you work quickly and integrate systems more effectively.}
}

module-whatis {Python 3.11.3: https://python.org/}

set root /opt/software/Python/3.11.3

prereq GCCcore/12.3.0
prereq zlib/1.2.13
prereq libffi/3.4.4
prereq bzip2/1.0.8
prereq SQLite/3.42.0
prereq OpenSSL/1.1.1t
prereq ncurses/6.4

conflict Python

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man
prepend-path PYTHONPATH $root/lib/python3.11/site-packages

setenv EBROOTPYTHON $root
setenv EBVERSIONPYTHON 3.11.3
