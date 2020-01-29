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
# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=pciutils
VER=3.6.4
PKG=system/pciutils
SUMMARY="PCI device utilities"
DESC="Programs (lspci, setpci) for inspecting and manipulating configuration "
DESC+="of PCI devices"

RUN_DEPENDS_IPS="system/pciutils/pci.ids"

set_arch 64

export PATH=/usr/gnu/bin:$PATH

configure64() {
    LDFLAGS+=" $LDFLAGS64"
    export LDFLAGS CC PREFIX
}

make_prog() {
    logmsg "--- make"
    logcmd $MAKE PREFIX=$PREFIX \
        OPT="-O2 -m64 -DBYTE_ORDER=1234 -DLITTLE_ENDIAN=1234" \
        || logerr "--- Make failed"
}

make_install() {
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} PREFIX=$PREFIX install \
        || logerr "--- Make install failed"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
