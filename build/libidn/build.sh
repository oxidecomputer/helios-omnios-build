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
# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/build.sh

PROG=libidn
VER=1.41
PKG=library/libidn
SUMMARY="The Internationalized Domains Library"
DESC="IDN - The Internationalized Domains Library"

CONFIGURE_OPTS="--disable-static"
MAKE_ARGS="MAKEINFO=/usr/bin/true"
MAKE_INSTALL_ARGS="$MAKE_ARGS"

init
prep_build

note -n "Building current version: $VER"
download_source $PROG $PROG $VER
patch_source
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
