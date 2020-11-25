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

PROG=idnkit
VER=2.3
PKG=library/idnkit
SUMMARY="Internationalized Domain Name kit (idnkit/JPNIC)"
DESC="Internationalized Domain Name kit (idnkit/JPNIC)"

CONFIGURE_OPTS="--disable-static --mandir=/usr/share/man"
LIBTOOL_NOSTDLIB=libtool
LIBTOOL_NOSTDLIB_EXTRAS="-lc -lssp_ns"

install_legacy()
{
    # Include libraries from idnkit1
    ver=1.0.2
    for lib in idnkit idnkitlite; do
        logcmd cp /usr/lib/lib$lib.so.$ver $DESTDIR/usr/lib/
        logcmd cp /usr/lib/amd64/lib$lib.so.$ver $DESTDIR/usr/lib/amd64/
        logcmd ln -s lib$lib.so.$ver $DESTDIR/usr/lib/lib$lib.so.1
        logcmd ln -s lib$lib.so.$ver $DESTDIR/usr/lib/amd64/lib$lib.so.1
    done
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
install_legacy
make_package lib.mog

PKG=library/idnkit/header-idnkit
DEPENDS_IPS=""
SUMMARY="Internationalized Domain Name Support Developer Files"
DESC="Internationalized Domain Name Support Developer Files"
make_package headers.mog

PKG=network/dns/idnconv
DEPENDS_IPS="library/idnkit"
SUMMARY="Internationalized Domain Name Support Utilities"
DESC="Internationalized Domain Name Support Utilities"
make_package bin.mog

clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
