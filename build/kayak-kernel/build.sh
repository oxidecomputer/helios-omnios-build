#!/usr/bin/bash

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
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
#

. ../../lib/functions.sh

PROG=kayak-kernel
PKG=system/install/kayak-kernel
VER=1.1
SUMMARY="Kayak - network installer media"
DESC="The kernel components of the kayak network installer"

if [ -n "$SKIP_KAYAK_KERNEL" ]; then
    logmsg "Skipping kayak-kernel build"
    exit 0
fi

# A kayak-kernel build requires access to bits of an illumos proto
# area such as the `svccfg-native` utility. If the check is skipped, then
# the build will still work but will use bits from the running system.
check_for_prebuilt

# pfexec will always work as a nop for root
[ "$UID" = 0 ] && PFEXEC=pfexec

# Check if privilege escalation is working
logmsg -n "-- escalating privileges with $PFEXEC"
[ "`$PFEXEC id -u`" = "0" ] || logerr "Cannot escalate privileges with $PFEXEC"

# If PKGURL is specified, allow it to be different than the destination
# PKGSRVR. PKGURL is the repository from which kayak-kernel takes its bits,
# PKGSRVR is where this package (with a prebuilt miniroot and unix) will be
# published.
: "${PKGURL:=$PKGSRVR}"
[ "$PKGURL" = "$PKGSRVR" ] || logmsg -n "Will source packages from $PKGURL"

# Respect environmental overrides for these to ease development.
: ${KAYAK_SOURCE_REPO:=$GITHUB/kayak}
: ${KAYAK_SOURCE_BRANCH:=r$RELVER}

clone_source() {
    clone_github_source kayak \
        "$KAYAK_SOURCE_REPO" "$KAYAK_SOURCE_BRANCH" "$KAYAK_CLONE"

    gdir=$TMPDIR/$BUILDDIR/kayak
    GITREV=`$GIT -C $gdir log -1  --format=format:%at`
    COMMIT=`$GIT -C $gdir log -1  --format=format:%h`
    REVDATE=`echo $GITREV | gawk '{ print strftime("%c %Z",$1) }'`
    VERHUMAN="${COMMIT:0:7} from $REVDATE"
}

clobber() {
    logmsg "-- removing any old kayak_image dataset"
    pushd $TMPDIR/$BUILDDIR/kayak >/dev/null || logerr "chdir"
    logcmd $PFEXEC gmake zfsdestroy
    popd >/dev/null
}

reset_owner() {
    # Reset ownership on files copied as root.
    logcmd $PFEXEC chown -R `id -un` $DESTDIR
}

build() {
    pushd $TMPDIR/$BUILDDIR/kayak >/dev/null || logerr "chdir"
    logmsg "-- building miniroot"
    if ! logcmd $PFEXEC gmake \
        PREBUILT_ILLUMOS=$PREBUILT_ILLUMOS \
        DESTDIR=$DESTDIR \
        VERSION=r$RELVER \
        PKGURL=$PKGURL \
        install-tftp; then
            reset_owner
            logerr "miniroot build failed"
    fi
    reset_owner
    popd >/dev/null
}

init
prep_build
clone_source
clobber
build
make_package kayak-kernel.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
