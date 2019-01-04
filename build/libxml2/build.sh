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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=libxml2
VER=2.9.9
PKG=library/libxml2
SUMMARY="XML C parser and toolkit"
DESC="Portable XML parser and toolkit library"

RUN_DEPENDS_IPS="compress/xz library/zlib"

XFORM_ARGS="-D VER=$VER"

CONFIGURE_OPTS+=" --without-python"

TESTSUITE_FILTER="^(Total|[Tt]esting|Ran)"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_isa_stub
make_package local.mog final.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
