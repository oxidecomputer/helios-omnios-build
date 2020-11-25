#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=net-snmp
VER=5.9
PKG=system/management/snmp/net-snmp
SUMMARY="Net-SNMP Agent files and libraries"
DESC="$SUMMARY"

NO_PARALLEL_MAKE=true
SKIP_LICENCES="CMU/UCD"

RUN_DEPENDS_IPS="shell/bash"

# Previous versions that also need to be built and the libraries packaged
# since compiled software may depend on them.
PVERS="5.7.3 5.8"

MIB_MODULES="host disman/event-mib ucd-snmp/diskio udp-mib tcp-mib if-mib"

CFLAGS+=" -fstack-check"
LDFLAGS32="-Wl,-zignore $LDFLAGS32 -L/lib"
LDFLAGS64="-Wl,-zignore $LDFLAGS64 -L/lib/$ISAPART64"
LNETSNMPLIBS="-lsocket -lnsl"

LIBRARIES_ONLY="
    --disable-agent
    --disable-applications
    --disable-manuals
    --disable-scripts
    --disable-mibs
"

forgo_isaexec
CONFIGURE_OPTS_32+=" $LIBRARIES_ONLY"

CONFIGURE_OPTS="
    --with-defaults
    --with-default-snmp-version=3
    --includedir=$PREFIX/include
    --mandir=$PREFIX/share/man
    --with-logfile=/var/log/snmpd.log
    --with-persistent-directory=/var/net-snmp
    --with-mibdirs=/etc/net-snmp/snmp/mibs
    --datadir=/etc/net-snmp
    --enable-agentx-dom-sock-only
    --enable-ucd-snmp-compatibility
    --enable-ipv6
    --enable-mfd-rewrites
    --enable-blumenthal-aes
    --disable-embedded-perl
    --without-perl-modules
    --disable-static
    --with-sys-contact=root@localhost
    --without-pkcs
    --with-openssl=/usr/ssl
"

CONFIGURE_OPTS_WS="
    --with-transports=\"Unix UDP TCP UDPIPv6 TCPIPv6\"
    --with-mib-modules=\"$MIB_MODULES\"
    LNETSNMPLIBS=\"$LNETSNMPLIBS\"
"

TESTSUITE_SED="
    1,/^..RUNFULLTESTS/d
    s/([^)]*net-snmp-.*//
    /^gmake/d
"

init
prep_build

# We only want the libraries from legacy versions
save_buildenv
CONFIGURE_OPTS_64+=" $LIBRARIES_ONLY"
for pver in $PVERS; do
    note -n "Building previous version: $pver"
    build_dependency -merge -ctf $PROG-$pver $PROG-$pver $PROG $PROG $pver
done
restore_buildenv
# Remove unnecessary files from the legacy versions
logcmd rm -rf $DESTDIR/usr/{include,bin}
logcmd $FD lib $DESTDIR/usr/lib -e la -e so -X rm {}

note -n "Building current version: $VER"
download_source $PROG $PROG $VER
patch_source
# The source archive for version 5.9 includes some .o files that need cleaning
CLEAN_SOURCE=
build
run_testsuite test
install_smf application/management net-snmp.xml svc-net-snmp
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
