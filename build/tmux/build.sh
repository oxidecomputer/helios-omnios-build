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
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=tmux
VER=2.8
VERHUMAN=$VER
PKG=terminal/tmux
SUMMARY="Terminal multiplexer"
DESC="$SUMMARY"
LIBEVENT_VER=2.1.8
LIBEVENT_DIR=libevent-${LIBEVENT_VER}-stable
XFORM_ARGS+=" -DLIBEVENT=$LIBEVENT_VER"

BUILD_DEPENDS_IPS=library/ncurses

init
prep_build

set_arch 64

#########################################################################
# Download and build a static version of libevent

CONFIGURE_OPTS="
    --prefix=/usr
    --disable-shared
"

build_dependency libevent $LIBEVENT_DIR \
    libevent libevent ${LIBEVENT_VER}-stable

#########################################################################

CPPFLAGS=" \
    -I$DEPROOT/usr/include -I$DEPROOT/usr/include/event2 \
    -I/usr/include/ncurses \
"
LDFLAGS="-L$DEPROOT/usr/lib/amd64 -lsocket -lnsl -lsendfile"

download_source $PROG $PROG $VER
patch_source
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
