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

PROG=tmux
VER=2.9a
VERHUMAN=$VER
PKG=terminal/tmux
SUMMARY="Terminal multiplexer"
DESC="$SUMMARY"
LIBEVENT_VER=2.1.11
LIBEVENT_DIR=libevent-${LIBEVENT_VER}-stable
XFORM_ARGS+=" -DLIBEVENT=$LIBEVENT_VER"

BUILD_DEPENDS_IPS=library/ncurses
SKIP_LICENCES=tmux

init
prep_build

set_arch 64

#########################################################################
# Download and build a static version of libevent

CONFIGURE_OPTS="
    --prefix=/usr
    --disable-shared
"

save_function configure64 _configure64

configure64(){
    run_autoreconf -fi
    _configure64
}

build_dependency libevent $LIBEVENT_DIR \
    libevent libevent ${LIBEVENT_VER}-stable

save_function _configure64 configure64

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
# Unusually, there was a 2.9a. Change this to 2.9.1
# Can likely be removed once 2.10 is released or if tmux begin to make a habit
# of using letter suffixes, it can be extended to make use of 'ord26'
VER=${VER//a/.1} make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
