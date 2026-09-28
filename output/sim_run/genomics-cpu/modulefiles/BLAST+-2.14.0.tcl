#%Module1.0
##
## BLAST_plus-2.14.0 modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/BLAST+-2.14.0.eb.
##
proc ModulesHelp { } {
    puts stderr {Basic Local Alignment Search Tool, or BLAST, is an algorithm for comparing primary biological sequence information.}
}

module-whatis {BLAST_plus 2.14.0: https://blast.ncbi.nlm.nih.gov/}

set root /opt/software/BLAST_plus/2.14.0

prereq GCC/12.3.0
prereq OpenMPI/4.1.5
prereq zlib/1.2.13

conflict BLAST_plus

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTBLAST_PLUS $root
setenv EBVERSIONBLAST_PLUS 2.14.0
