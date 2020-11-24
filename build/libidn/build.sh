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
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=libidn
VER=1.36
PKG=library/libidn
SUMMARY="The Internationalized Domains Library"
DESC="IDN - The Internationalized Domains Library"

CONFIGURE_OPTS="--disable-static"

init
prep_build

# The library major version changed from 11 to 12 with 1.35. We need to
# continue shipping the older version of the library to support anything
# linked against it. This builds both versions in order.
for VER in 1.34 $VER; do
    set_builddir "$PROG-$VER"
    download_source $PROG $PROG $VER
    patch_source
    build
done

make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
