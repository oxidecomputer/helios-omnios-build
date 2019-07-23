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

PROG=coreutils
VER=8.31
PKG=file/gnu-coreutils
SUMMARY="coreutils - GNU core utilities"
DESC="GNU core utilities"

BUILD_DEPENDS_IPS="compress/xz library/gmp"

PREFIX=/usr/gnu

# We ship 64-bit binaries under /usr/gnu/bin/ with selected ones linked back
# to /usr/bin/, but we need to continue building dual arch so that the
# 32-bit libstdbuf.so is available. This enables the stdbuf command to
# work with 32-bit binaries.
set_arch both

CPPFLAGS="-I/usr/include/gmp"
CONFIGURE_OPTS+="
    --with-openssl=auto
    gl_cv_host_operating_system=illumos
    ac_cv_func_inotify_init=no
"
CONFIGURE_OPTS_32+="
    --bindir=/usr/gnu/bin/__i386
    --libexecdir=/usr/lib
"
CONFIGURE_OPTS_64+="
    --libexecdir=/usr/lib/$ISAPART64
"

TESTSUITE_FILTER='^[A-Z#][A-Z ]'

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
