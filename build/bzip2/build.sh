#!/usr/bin/bash
#
# {{{ CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END }}}
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=bzip2
VER=1.0.8
PKG=compress/bzip2
SUMMARY="The bzip compression utility"
DESC="A patent free high-quality data compressor"

SKIP_LICENCES=bzip2
XFORM_ARGS="-D VER=$VER"

# We don't use configure, so explicitly export PREFIX
PREFIX=/usr
export PREFIX
export CC

base_CFLAGS="$CFLAGS -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -Wall -Winline"

configure32() {
    BINISA=$ISAPART
    LIBISA=""
    CFLAGS="$CFLAGS32 $base_CFLAGS"
    LDFLAGS="$LDFLAGS $LDFLAGS32"
    export BINISA LIBISA CFLAGS LDFLAGS
}

configure64() {
    BINISA=$ISAPART64
    LIBISA=$ISAPART64
    CFLAGS="$CFLAGS64 $base_CFLAGS"
    LDFLAGS="$LDFLAGS $LDFLAGS64"
    export BINISA LIBISA CFLAGS LDFLAGS
}

save_function make_clean make_clean_orig
make_clean() {
    make_clean_orig
    logcmd $MAKE -f Makefile-libbz2_so clean
}

# We need to build the shared lib using a second Makefile
make_shlib() {
    [ -n "$NO_PARALLEL_MAKE" ] && MAKE_JOBS=
    logmsg "--- make (shared lib)"
    OLD_CFLAGS=$CFLAGS
    CFLAGS="-fPIC $CFLAGS"
    export CFLAGS
    logcmd $MAKE $MAKE_JOBS -f Makefile-libbz2_so || \
        logerr "--- Make failed (shared lib)"
    CFLAGS=$OLD_CFLAGS
    export CFLAGS
}

make_shlib_install() {
    logmsg "--- make install (shared lib)"
    logcmd $MAKE DESTDIR=${DESTDIR} -f Makefile-libbz2_so install || \
        logerr "--- Make install failed (shared lib)"
}

build32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 32-bit"
    export ISALIST="$ISAPART"
    make_clean
    configure32
    make_shlib
    make_prog32
    make_install32
    popd > /dev/null
    unset ISALIST
    export ISALIST
}

build64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 64-bit"
    make_clean
    configure64
    make_shlib
    make_prog64
    make_install64
    popd > /dev/null
}

TESTSUITE_SED="
    /in business/q
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
strip_install
run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
