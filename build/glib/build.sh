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
#
. ../../lib/functions.sh

PROG=glib
VER=2.60.0
PKG=library/glib2
SUMMARY="GNOME utility library"
DESC="The GNOME general-purpose utility library"

set_python_version $PYTHON3VER
BUILDARCH=both

BUILD_DEPENDS_IPS="library/python-${PYTHONVER%%.*}/meson-$PYTHONPKGVER"

RUN_DEPENDS_IPS="
    runtime/python-$PYTHONPKGVER
    runtime/perl-64
"

# use GNU msgfmt; otherwise the build fails
PATH="/usr/gnu/bin:$PATH:/opt/ooce/bin"

# With gcc 6 and above, -Werror_format=2 produces errors like:
#   error: format not a string literal, arguments not checked
# Tell configure that this flag doesn't exist for the compiler.
CFLAGS+=" -Wno-error=format-nonliteral -Wno-error=format=2"

# Required to enable the POSIX variants of getpwuid_r and getpwnam_r
# See comment in /usr/include/pwd.h
CFLAGS+=" -D_XPG6 -D_POSIX_PTHREAD_SEMANTICS"

LDFLAGS+=" -Wl,-z,ignore"

CONFIGURE_CMD="$PYTHONLIB/python$PYTHONVER/bin/meson setup _build"

MAKE="ninja -C _build"

TESTSUITE_MAKE=$MAKE

CONFIGURE_OPTS="
    --prefix=$PREFIX
    -Dfam=false
    -Dxattr=false
    -Dforce_posix_threads=true
    -Ddtrace=false
    -Db_asneeded=false
"
CONFIGURE_OPTS_32="
    --bindir=$PREFIX/bin
    --libdir=$PREFIX/lib
"
CONFIGURE_OPTS_64="
    --bindir=$PREFIX/bin
    --libdir=$PREFIX/lib/$ISAPART64
"

TESTSUITE_SED='
    # Remove elapsed time
    s/ *[0-9][0-9]*\.[0-9][0-9] s .*//
    # Strip failed test output
    /^The output from .* first failed/,$d
'

make_clean() {
    logmsg "--- make (dist)clean"
    [ -d $TMPDIR/$BUILDDIR/_build ] && logcmd rm -rf $TMPDIR/$BUILDDIR/_build
}

make_install() {
    logmsg "--- make install"
    DESTDIR=$DESTDIR logcmd $MAKE $args $MAKE_INSTALL_ARGS install \
        || logerr "--- Make install failed"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
