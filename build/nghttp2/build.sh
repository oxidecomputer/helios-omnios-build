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
# Copyright 2011-2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=nghttp2
VER=1.39.2
PKG=library/nghttp2
SUMMARY="nghttp2: HTTP/2 C Library"
DESC="An implementation of the Hypertext Transfer Protocol version 2 in C"

BUILD_DEPENDS_IPS="ooce/developer/cunit"

LDFLAGS="-lm"
CONFIGURE_OPTS="
    --enable-lib-only
    --disable-silent-rules
"

export ZLIB_CFLAGS="$CFLAGS -I/usr/include"
export ZLIB_LIBS="-L/usr/lib"
export OPENSSL_CFLAGS="$CFLAGS -I/usr/include"
export OPENSSL_LIBS="-L/usr/lib"
export CUNIT_CFLAGS="$CFLAGS -I/opt/ooce/include"
export CUNIT_LIBS="-L/opt/ooce/lib/amd64 -R/opt/ooce/lib/amd64 -lcunit"

TESTSUITE_SED="
    /^libtool:/d
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build -ctf
run_testsuite check
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
