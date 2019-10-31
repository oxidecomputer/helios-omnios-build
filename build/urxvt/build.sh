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
# Copyright 2014 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

# The rxvt-unicode terminfo definition is not shipped by ncurses.
# See https://invisible-island.net/ncurses/ncurses-urxvt.html

PROG=rxvt-unicode
VER=9.22
PKG=system/data/urxvt-terminfo
SUMMARY="terminfo definition for rxvt-unicode"
DESC="$SUMMARY"

build() {
    TERMINFO=${DESTDIR}/usr/gnu/share/terminfo
    logcmd mkdir -p $TERMINFO
    logcmd /usr/gnu/bin/tic -xo $TERMINFO \
        $TMPDIR/$BUILDDIR/doc/etc/${PROG}.terminfo \
        || logerr 'failed to install terminfo file for ncurses'
}

init
download_source $PROG $PROG $VER
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
