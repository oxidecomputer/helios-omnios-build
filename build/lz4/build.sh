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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=lz4
PKG=compress/lz4
VER=1.9.3
SUMMARY="LZ4"
DESC="Extremely fast compression"

# we build/ship 32 and 64-bit libraries but only 64-bit binaries
configure32() {
    MAKE_ARGS_WS="
        CFLAGS=\"$CFLAGS $CFLAGS32\"
        LDFLAGS=\"$LDFLAGS $LDFLAGS32\"
    "
}

configure64() {
    MAKE_ARGS_WS="
        CFLAGS=\"$CFLAGS $CFLAGS64\"
        LDFLAGS=\"$LDFLAGS $LDFLAGS64\"
    "
}

MAKE_INSTALL_ARGS="
    INSTALL=$GNUBIN/install
    PREFIX=$PREFIX
"
MAKE_INSTALL_ARGS_32="LIBDIR=$PREFIX/lib BINDIR=$PREFIX/bin/$ISAPART"
MAKE_INSTALL_ARGS_64="LIBDIR=$PREFIX/lib/$ISAPART64"

MAKE_TESTSUITE_ARGS="$MAKE_INSTALL_ARGS"

init
download_source $PROG "v$VER"
patch_source
prep_build
build
PATH=$GNUBIN:$PATH run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
