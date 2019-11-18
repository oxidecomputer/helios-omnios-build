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

# Copyright (c) 2014 by Delphix. All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=pkg-config
VER=0.29.2
PKG=developer/pkg-config
SUMMARY="A tool for generating compiler command line options"
DESC="pkg-config is a helper tool used when compiling applications and libraries that helps you insert the correct compiler options on the command line, rather than hard-coding values on where to find libraries."

HARDLINK_TARGETS="
    usr/bin/i386/$TRIPLET64-pkg-config
    usr/bin/amd64/$TRIPLET64-pkg-config
"

init
download_source $PROG $PROG $VER
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
