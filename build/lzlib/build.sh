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

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=lzlib
PKG=library/lzlib
VER=1.13
SUMMARY="Data compression library"
DESC="$SUMMARY providing in-memory LZMA (de-)compression functions"

CONFIGURE_OPTS="
    --disable-static
"

SKIP_LICENCES=lzlib

save_function configure32 _configure32
configure32() {
    CONFIGURE_OPTS_WS_32="
        CC=\"$CC\"
        CPPFLAGS=\"$CPPFLAGS $CPPFLAGS32\"
        CFLAGS=\"$CFLAGS $CFLAGS32\"
        LDFLAGS=\"$LDFLAGS $LDFLAGS32\"
    "
    _configure32 "$@"
}

save_function configure64 _configure64
configure64() {
    CONFIGURE_OPTS_WS_64="
        CC=\"$CC\"
        CPPFLAGS=\"$CPPFLAGS $CPPFLAGS64\"
        CFLAGS=\"$CFLAGS $CFLAGS64\"
        LDFLAGS=\"$LDFLAGS $LDFLAGS64\"
    "
    _configure64 "$@"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
