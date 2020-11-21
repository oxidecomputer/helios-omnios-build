#!/usr/bin/bash

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

# Copyright 2015 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=zlib
VER=1.2.11
PKG=library/zlib
SUMMARY="$PROG - A compression library"
DESC="$SUMMARY"

DEPENDS_IPS="system/library/gcc-runtime"
SKIP_LICENCES=zlib

CFLAGS+=" -DNO_VIZ"
LDFLAGS32+=" -lssp_ns"

CONFIGURE_OPTS_32="--prefix=$PREFIX
    --includedir=$PREFIX/include
    --libdir=$PREFIX/lib"

CONFIGURE_OPTS_64="--prefix=$PREFIX
    --includedir=$PREFIX/include
    --libdir=$PREFIX/lib/$ISAPART64"

install_license(){
    # This is fun, take from the zlib.h header
    /bin/awk '/Copyright/,/\*\//{if($1 != "*/"){print}}' \
        $TMPDIR/$BUILDDIR/zlib.h > $DESTDIR/license
}

make_prog32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd gmake LDSHARED="gcc -shared -nostdlib" || logerr "gmake failed"
    popd > /dev/null
}

make_prog64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd gmake LDSHARED="gcc -shared -nostdlib" || logerr "gmake failed"
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite
install_license
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
