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
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=libffi
VER=3.3
VERHUMAN=$VER
PKG=library/libffi
SUMMARY="A Portable Foreign Function Interface Library"
DESC="$SUMMARY"

SKIP_LICENCES=libffi

# Previous versions that also need to be built and packaged since compiled
# software may depend on it.
PVERS="3.2.1"

# libffi has historically been linked with libtool's -nostdlib.
# The exact reason for this unclear but historic commit messages indicate that
# it may be related to C++ throw/catch across the library interface.
# We should try and clarify the exact reason but we retain the same link
# behavour.

save_function make_prog _make_prog
make_prog() {
    _make_prog
    logmsg "--- rebuilding libraries with -nostdlib -lc"
    pushd $TRIPLET64 >/dev/null || logerr "pushd"
    libtool_nostdlib libtool -lc
    logcmd $MAKE clean all || logerr "Rebuild with -nostdlib failed"
    popd >/dev/null
}

tests() {
    nm $TMPDIR/$BUILDDIR/$TRIPLET64/.libs/libffi.so | egrep '\|_(init|fini)' \
        && logerr "libffi was linked against standard libraries."
}

init
prep_build

# Build previous versions
for pver in $PVERS; do
    note -n "Building previous version: $pver"
    save_variable BUILDDIR
    BUILDDIR=$PROG-$pver
    download_source $PROG $PROG $pver
    build
    tests
    restore_variable BUILDDIR
done

note -n "Building current version: $VER"
download_source $PROG $PROG $VER
patch_source
build
tests
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
