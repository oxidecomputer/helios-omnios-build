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
# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=libxslt
VER=1.1.30
PKG=library/libxslt
SUMMARY="The XSLT C library"
DESC="The portable XSLT C library built on libxml2"

CFLAGS32+=" -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
CFLAGS64+=" -D_LARGEFILE_SOURCE"
LDFLAGS="-lpthread"

# Without --with-libxml-prefix, configure does not find /usr/bin/xml2-config!
CONFIGURE_OPTS="
    --disable-static
    --with-pic
    --without-crypto
    --with-libxml-prefix=/usr
    --without-python
"

# Make clean removes the man page (xsltproc.1) so it is preserved and
# restored between flavours (see below). However, this makes the tree
# end up with this file missing. Force removal of any previous extracted
# source trees to start from a clean slate.
REMOVE_PREVIOUS=1
SKIP_LICENCES=libxslt

backup_man() {
    logmsg "making a backup of xsltproc.1"
    logcmd cp $TMPDIR/$BUILDDIR/doc/xsltproc.1 $TMPDIR/$BUILDDIR/backup.1
}

save_function configure64 _configure64
configure64() {
    _configure64
    logmsg "restoring backup of xsltproc.1"
    [ -f $TMPDIR/$BUILDDIR/doc/xsltproc.1 ] && logerr "xsltproc.1 fixed!"
    logcmd cp $TMPDIR/$BUILDDIR/backup.1 $TMPDIR/$BUILDDIR/doc/xsltproc.1
    logcmd touch $TMPDIR/$BUILDDIR/doc/xsltproc.1
}

tests() {
    logmsg "-- running tests"
    [ `$DESTDIR/usr/bin/xslt-config --cflags` = "-I/usr/include/libxml2" ] \
        || logerr "xslt-config --cflags not working"
}

init
download_source $PROG $PROG $VER
patch_source
run_autoreconf
backup_man
prep_build
build
make_isa_stub
tests
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
