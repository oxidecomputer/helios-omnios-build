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
# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=tmux
VER=3.0
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
