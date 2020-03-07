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

# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=ntp
VER=4.2.8p14
PKG=service/network/ntp
SUMMARY="Network Time Services"
DESC="An implementation of Network Time Protocol Version 4"

set_arch 64

CONFIGURE_OPTS_64+="
    --bindir=/usr/sbin
    --with-binsubdir=sbin
    --libexecdir=/usr/lib/inet
    --sysconfdir=/etc/inet
    --with-openssl-libdir=/lib
"

CONFIGURE_OPTS="
    --enable-all-clocks
    --enable-debugging
    --enable-debug-timing
    --disable-optional-args
    --enable-parse-clocks
    --enable-ignore-dns-errors
    --without-ntpsnmpd
    --without-sntp
    --without-lineeditlibs
"

SKIP_LICENCES="UD Open Source"
TESTSUITE_FILTER='^[A-Z#][A-Z ]'

overlay_root() {
    (cd $SRCDIR/root && tar cf - .) | (cd $DESTDIR && tar xf -)
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
overlay_root
install_smf network ntp.xml ntp
VERHUMAN=$VER
VER=${VER//p/.}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
