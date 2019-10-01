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
# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=libpcap
VER=1.9.1
VERHUMAN=$VER
PKG=system/library/pcap
SUMMARY="libpcap - a packet capture library"
DESC="$SUMMARY"

CONFIGURE_OPTS="
    --mandir=/usr/share/man
    --with-pcap=dlpi
"

fixup_man3(){
    mv $DESTDIR/usr/share/man/man3 $DESTDIR/usr/share/man/man3pcap
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
run_autoconf
build
make_isa_stub
fixup_man3
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
