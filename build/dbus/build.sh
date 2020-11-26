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
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=dbus
VER=1.12.20
PKG=dbus ##IGNORE##
SUMMARY="filled in below"
DESC="$SUMMARY"

set_standard XPG6
CPPFLAGS+=" -D_REENTRANT"

CONFIGURE_OPTS="
    --with-dbus-daemondir=/usr/lib
    --bindir=/usr/bin
    --localstatedir=/var
    --libexecdir=/usr/libexec
    --with-x=no
    --with-dbus-user=root
    --disable-static
    --disable-inotify
"

export MAKE

post_install() {
    mkdir -p $DESTDIR/etc/security/auth_attr.d
    mkdir -p $DESTDIR/etc/security/prof_attr.d
    cp $SRCDIR/files/auth-system%2Flibrary%2Fdbus \
        $DESTDIR/etc/security/auth_attr.d/system%2Flibrary%2Fdbus
    cp $SRCDIR/files/prof-system%2Flibrary%2Fdbus \
        $DESTDIR/etc/security/prof_attr.d/system%2Flibrary%2Fdbus
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_isa_stub
install_smf system dbus.xml svc-dbus
post_install

PKG=system/library/dbus
SUMMARY="Simple IPC library based on messages"
DESC="A simple system for interprocess communication and coordination"
make_package dbus.mog

PKG=system/library/libdbus
SUMMARY+=" - client libraries"
DESC+=" - client libraries"
make_package libdbus.mog

clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
