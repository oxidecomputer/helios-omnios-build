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

# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=pkgtree
VER=1.1
PKG=system/pkgtree
SUMMARY="pkgtree displays the IPS package dependency tree."
DESC="pkgtree takes package information from the running system, caches it, then displays dependency information for all packages or for an individual package selected by pkg_fmri."

BUILD_DEPENDS_IPS="network/rsync"
RUN_DEPENDS_IPS="runtime/perl"

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    VENDOR_DIR+="`/usr/bin/perl -V:installvendorlib | cut -d\' -f2`"
    logmsg "Copying files"
    logcmd mkdir -p $DESTDIR/$VENDOR_DIR \
        || logerr "--- Failed to make vendor_perl dir"
    logcmd rsync -a lib/perl5/ $DESTDIR/$VENDOR_DIR/ \
        || logerr "--- Failed to copy files"
    logcmd mkdir $DESTDIR$PREFIX/bin || logerr "--- Failed to make bin dir"
    logcmd rsync -a bin/ $DESTDIR$PREFIX/bin/ \
        || logerr "--- Failed to install bins"

    MAN_DIR="$DESTDIR$PREFIX/share/man/man1"
    POD2MAN="/usr/perl5/bin/pod2man"
    logmsg "Creating man page"
    logcmd mkdir -p $MAN_DIR || logerr "--- Failed to make man1 dir"
    logcmd $POD2MAN bin/pkgtree $MAN_DIR/pkgtree.1 \
        || logerr "--- Failed to make man page"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
