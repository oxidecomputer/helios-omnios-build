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
#
. ../../lib/functions.sh

PROG=vim
VER=8.2
PATCHLEVEL=0
PKG=editor/vim
SUMMARY="Vi IMproved"
DESC="Advanced text editor that provides the power of the UNIX vi editor "
DESC+="with a more complete feature set."

SVER=${VER//./}
set_builddir "$PROG$SVER"

set_arch 64

XFORM_ARGS+=" -D SVER=$SVER"

SKIP_LICENCES="*"

# VIM 8.0 source exposes either a bug in illumos msgfmt(1), OR it contains
# a GNU-ism we are strict about.  Either way, use GNU msgfmt for now.
export MSGFMT=/usr/gnu/bin/msgfmt

CONFIGURE_OPTS="
    --with-features=huge
    --without-x
    --disable-gui
    --disable-gtktest
"

extract_licence() {
    sed -n < $DESTDIR/usr/share/vim/vim$SVER/doc/uganda.txt \
           > $DESTDIR/usr/share/vim/vim$SVER/LICENCE '
        /=== begin of license ===/,/=== end of license ===/p
    '
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
extract_licence
VER+=".$PATCHLEVEL"
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
