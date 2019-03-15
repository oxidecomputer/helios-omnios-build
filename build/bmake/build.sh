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
# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=bmake
VER=20181221
PKG=developer/bmake
SUMMARY="BSD make tool"
DESC="Portable version of NetBSD make(1)"

set_builddir bmake
set_arch 64

CONFIGURE_OPTS="--prefix=$PREFIX"
# prefix doesn't get built into the binary correctly for some reason with just
# configure
export MAKEFLAGS="prefix=$PREFIX"
# bmake is apparently called with "-j observer-fds=3,4" or something if -j was
# given to gmake, which makes no sense. just build non-parallel
NO_PARALLEL_MAKE=1

extract_licence() {
    sed '/ifndef/{
        d
        q
    }' < $TMPDIR/$BUILDDIR/main.c > $TMPDIR/$BUILDDIR/LICENCE
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
extract_licence
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
