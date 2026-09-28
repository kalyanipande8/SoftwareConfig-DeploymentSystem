#%Module1.0
##
## HDF5-1.14.0 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/HDF5-1.14.0.eb.
##
proc ModulesHelp { } {
    puts stderr {HDF5 is a data model, library, and file format for storing and managing data.}
}

module-whatis {HDF5 1.14.0: https://www.hdfgroup.org/solutions/hdf5/}

set root /opt/software/HDF5/1.14.0

prereq GCC/12.3.0
prereq OpenMPI/4.1.5
prereq zlib/1.2.13

conflict HDF5

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTHDF5 $root
setenv EBVERSIONHDF5 1.14.0
