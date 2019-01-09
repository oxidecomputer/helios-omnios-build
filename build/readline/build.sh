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
# Use is subject to license terms.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=readline
VER=8.0
PKG=library/readline
SUMMARY="GNU readline"
DESC="GNU readline library"

# Previous versions that also need to be built and packaged since compiled
# software may depend on it.
PVERS="6.3 7.0"

CONFIGURE_OPTS="--disable-static"

init
prep_build

# Build previous versions
for pver in $PVERS; do
    note -n "Building previous version: $pver"
    BUILDDIR=$PROG-$pver download_source $PROG $PROG $pver
    PATCHDIR=patches-${pver##.*} patch_source
    BUILDDIR=$PROG-$pver build
done

note -n "Building current version: $VER"
download_source $PROG $PROG $VER
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
