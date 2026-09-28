#%Module1.0
##
## SciPy-bundle-2023.05 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/SciPy-bundle-2023.05.eb.
##
proc ModulesHelp { } {
    puts stderr {Bundle of Python packages for scientific software including SciPy built on top of NumPy.}
}

module-whatis {SciPy-bundle 2023.05: https://www.scipy.org/}

set root /opt/software/SciPy-bundle/2023.05

prereq Python/3.11.3
prereq numpy/1.24.3
prereq OpenBLAS/0.3.23

conflict SciPy-bundle

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTSCIPY_BUNDLE $root
setenv EBVERSIONSCIPY_BUNDLE 2023.05
