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
# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=gmp
VER=6.1.2
PKG=library/gmp
SUMMARY="GNU MP"
DESC="The GNU Multiple Precision (Bignum) Library"

# Build library to use only common CPU features rather than those supported
# on the build machine.
MPN32="x86/pentium x86 generic"
MPN64="x86_64/pentium4 x86_64 generic"
export MPN32 MPN64

BUILD_DEPENDS_IPS=developer/build/libtool

TESTSUITE_SED="
    /^ *[a-z]/d
    /^Making /d
"

CFLAGS+=" -fexceptions"
CONFIGURE_OPTS="
    --includedir=$PREFIX/include/gmp
    --localstatedir=/var
    --enable-shared
    --disable-static
    --disable-libtool-lock
    --disable-alloca
    --enable-cxx
    --enable-fft
    --disable-fat
    --with-pic
"

CONFIGURE_OPTS_WS_32="
    ABI=32
    MPN_PATH=\"$MPN32\"
"

CONFIGURE_OPTS_WS_64="
    ABI=64
    MPN_PATH=\"$MPN64\"
"

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
