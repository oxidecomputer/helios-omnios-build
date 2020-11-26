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
# Copyright 2015 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=illumos-closed
VER=5.11
PKG=developer/illumos-closed
SUMMARY="illumos closed binaries"
DESC="Closed-source binaries required to build an illumos distribution."

BUILDDIR=closed

HARDLINK_TARGETS="
    opt/onbld/closed/root_i386/usr/xpg4/bin/alias
    opt/onbld/closed/root_i386-nd/usr/xpg4/bin/alias
    opt/onbld/closed/root_i386/platform/i86pc/kernel/cpu/cpu_ms.GenuineIntel.6.46
    opt/onbld/closed/root_i386/platform/i86pc/kernel/cpu/amd64/cpu_ms.GenuineIntel.6.46
    opt/onbld/closed/root_i386-nd/platform/i86pc/kernel/cpu/cpu_ms.GenuineIntel.6.46
    opt/onbld/closed/root_i386-nd/platform/i86pc/kernel/cpu/amd64/cpu_ms.GenuineIntel.6.46
    opt/onbld/closed/root_i386/etc/init.d/llc2
    opt/onbld/closed/root_i386-nd/etc/init.d/llc2
    opt/onbld/closed/root_i386/kernel/strmod/sdpib
    opt/onbld/closed/root_i386-nd/kernel/strmod/sdpib
    opt/onbld/closed/root_i386/kernel/strmod/amd64/sdpib
    opt/onbld/closed/root_i386-nd/kernel/strmod/amd64/sdpib
"

transfer_closed() {
    logcmd mkdir -p $DESTDIR/opt/onbld \
        || logerr "--- Failed to create proto directory"
    logcmd rsync -aH $TMPDIR/$BUILDDIR/ $DESTDIR/opt/onbld/closed/ \
        || logerr "rsync of closed failed"
}

install_archives() {
    logcmd cp $TMPDIR/on-closed-bins{,-nd}.i386.tar.bz2 \
        $DESTDIR/opt/onbld/closed/ \
        || logerr "Cannot copy archives into place."
}

init
prep_build
download_source on-closed on-closed-bins.i386 ""
transfer_closed
download_source on-closed on-closed-bins-nd.i386 ""
transfer_closed
install_archives
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
