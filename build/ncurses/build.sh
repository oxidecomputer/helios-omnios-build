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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=ncurses
VER=6.1-20190824
PKG=library/ncurses
SUMMARY="A CRT screen handling package"
DESC="Utilities and shared libraries for terminal handling"

DEPENDS_IPS="shell/bash system/library"

LD=/usr/ccs/bin/ld
export LD
GPREFIX=$PREFIX/gnu
CONFIGURE_OPTS_COMMON="
    --program-prefix=g
    --mandir=$GPREFIX/share/man
    --disable-overwrite
    --without-normal
    --with-shared
    --enable-widec
    --disable-lib-suffixes
    --without-debug
    --enable-string-hacks
    --enable-symlinks
    --includedir=$PREFIX/include/ncurses
    --prefix=$GPREFIX
    --with-terminfo-dirs=$GPREFIX/share/terminfo
    --with-default-terminfo-dir=$GPREFIX/share/terminfo
"
CONFIGURE_OPTS_ABI6="$CONFIGURE_OPTS_COMMON"
CONFIGURE_OPTS_ABI5="$CONFIGURE_OPTS_COMMON --with-abi-version=5"
CONFIGURE_OPTS_32="
    --bindir=$PREFIX/bin/$ISAPART"

CONFIGURE_OPTS_64="
    --bindir=$PREFIX/bin/$ISAPART64
    --libdir=$GPREFIX/lib/$ISAPART64"

gnu_links() {
    # put libncurses* in PREFIX/lib so other programs don't need to link
    # with rpath
    mkdir -p $DESTDIR/$PREFIX/lib/$ISAPART64
    mv $DESTDIR/$GPREFIX/lib/libncurses* $DESTDIR/$PREFIX/lib
    mv $DESTDIR/$GPREFIX/lib/$ISAPART64/libncurses* \
       $DESTDIR/$PREFIX/lib/$ISAPART64
}

build_abi5() {
    logmsg '--- Building backward-compatible ABI version 5 libraries.'
    CONFIGURE_OPTS="$CONFIGURE_OPTS_ABI5"
    MAKE_INSTALL_TARGET=install.libs
    build
}

build_abi6() {
    logmsg '--- Building ABI version 6.'
    CONFIGURE_OPTS="$CONFIGURE_OPTS_ABI6"
    MAKE_INSTALL_TARGET=install
    build
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build_abi5
build_abi6
make_isa_stub
gnu_links
VER=${VER/-/.}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
