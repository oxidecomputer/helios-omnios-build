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
# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=mdata-client
VER=20190228
PKG=system/management/mdata-client
SUMMARY="Cross-platform metadata client tools for use in SDC guests"
DESC="Metadata retrieval and manipulation tools for use within guests of the "
DESC+="SmartOS (and SDC) hypervisor. These guests may be either SmartOS Zones "
DESC+="or KVM virtual machines."

set_builddir "$PROG-release-$VER"

set_arch 32

# There is no configure step here
CONFIGURE_CMD=true
MAKE_ARGS_WS="CC=\"gcc -m$BUILDARCH\""

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
