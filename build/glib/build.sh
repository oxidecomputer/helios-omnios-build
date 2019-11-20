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

# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=glib
VER=2.62.3
PKG=library/glib2
SUMMARY="GNOME utility library"
DESC="The GNOME general-purpose utility library"

RUN_DEPENDS_IPS="
    runtime/python-$PYTHONPKGVER
    runtime/perl-64
"

# ninja does not support the --quiet option
MAKE_TESTSUITE_ARGS=

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

clean_testsuite() {
    local tf=testsuite.log.$$
    run_testsuite test "" $tf
    [ -s $SRCDIR/$tf ] && nawk '
        # Strip failed test output
        /^The output from .* first failed/ { exit }
        # Found a test
        /^ *[0-9][0-9]*\/[0-9]/ {
            # Remove elapsed time
            sub(/ *[0-9][0-9]*\.[0-9][0-9] s .*/, "")
            # Remove sequence number
            sub(/ *[0-9]*\/[0-9]* */, "")
            print | "sort"
            flag = 1
            next
        }
        flag { close "sort" }
        { print }
    ' < $SRCDIR/$tf > $SRCDIR/testsuite.log
    rm -f $SRCDIR/$tf
}

make_clean() {
    logmsg "--- make (dist)clean"
    [ -d $TMPDIR/$BUILDDIR ] && logcmd rm -rf $TMPDIR/$BUILDDIR
}

init
download_source $PROG $PROG $VER
patch_source
prep_build meson
build
clean_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
