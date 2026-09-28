#%Module1.0
##
## OpenSSL-1.1.1t modulefile
## Generated as reviewable infra-as-code for the SoftwareConfig-DeploymentSystem
## portfolio project (Environment Modules Tcl format). Matches the
## dependency declarations in easyconfigs/OpenSSL-1.1.1t.eb.
##
proc ModulesHelp { } {
    puts stderr {The OpenSSL Project is a collaborative effort to develop a robust, commercial-grade, full-featured toolkit for TLS and SSL protocols.}
}

module-whatis {OpenSSL 1.1.1t: https://www.openssl.org/}

set root /opt/software/OpenSSL/1.1.1t

prereq GCCcore/12.3.0

conflict OpenSSL

prepend-path PATH $root/bin
prepend-path LD_LIBRARY_PATH $root/lib
prepend-path LIBRARY_PATH $root/lib
prepend-path CPATH $root/include
prepend-path MANPATH $root/share/man

setenv EBROOTOPENSSL $root
setenv EBVERSIONOPENSSL 1.1.1t
