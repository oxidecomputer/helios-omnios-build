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

# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=coreutils
VER=8.32
PKG=file/gnu-coreutils
SUMMARY="coreutils - GNU core utilities"
DESC="GNU core utilities"

BUILD_DEPENDS_IPS="compress/xz library/gmp"

PREFIX=/usr/gnu

# We ship 64-bit binaries under $GNUBIN/ with selected ones linked back
# to /usr/bin/, but we need to continue building dual arch so that the
# 32-bit libstdbuf.so is available. This enables the stdbuf command to
# work with 32-bit binaries.
set_arch both
forgo_isaexec

# hardlinks are defined in local.mog
SKIP_HARDLINK=1

CPPFLAGS="-I/usr/include/gmp"
CONFIGURE_OPTS+="
    --with-openssl=auto
    gl_cv_host_operating_system=illumos
    ac_cv_func_inotify_init=no
"
CONFIGURE_OPTS_32+=" --libexecdir=/usr/lib"
CONFIGURE_OPTS_64+=" --libexecdir=/usr/lib/$ISAPART64"

TESTSUITE_FILTER='^[A-Z#][A-Z ]'

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
