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
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

# The following lines starting with PKG= let buildctl spot the packages that
# are actually built by the makefiles in the pkg source. Also build a package
# list to use later when showing package differences.
PKG=package/pkg
PKGLIST=$PKG
PKG=system/zones/brand/ipkg
PKGLIST+=" $PKG"
PKG=system/zones/brand/lipkg
PKGLIST+=" $PKG"
PKG=system/zones/brand/illumos
PKGLIST+=" $PKG"
PKG=system/zones/brand/sparse
PKGLIST+=" $PKG"
PKG=system/zones/brand/pkgsrc
PKGLIST+=" $PKG"
PKG=system/zones/brand/bhyve
PKGLIST+=" $PKG"
PKG=system/zones/brand/kvm
PKGLIST+=" $PKG"
PKG=system/zones/brand/lx/platform
PKGLIST+=" $PKG"
SUMMARY="This isn't used"
DESC="$SUMMARY"

PROG=pkg
VER=omni
BUILDNUM=$RELVER
if [ -z "$PKGPUBLISHER" ]; then
    logerr "No PKGPUBLISHER specified. Check lib/site.sh"
    exit
fi

BUILD_DEPENDS_IPS="
    developer/versioning/git
    system/zones/internal
    text/intltool
"

# Respect environmental overrides for these to ease development.
: ${PKG_SOURCE_REPO:=https://github.com/oxidecomputer/pkg5}
: ${PKG_SOURCE_BRANCH:=helios2.1}
VER+="-$PKG_SOURCE_BRANCH"

# Some python modules require rust for building
PATH+=:$OOCEBIN

clone_source() {
    clone_github_source pkg \
        "$PKG_SOURCE_REPO" "$PKG_SOURCE_BRANCH" "$PKG5_CLONE" 0
    ((EXTRACT_MODE)) && exit
}

build() {
    pushd $TMPDIR/$BUILDDIR/pkg/src > /dev/null || logerr "Cannot chdir"
    logmsg "--- build"
    logcmd make clean
    logcmd make || logerr "make failed"
    logmsg "--- install"
    logcmd make install || logerr "install failed"
    popd > /dev/null
}

package() {
    pushd $TMPDIR/$BUILDDIR/pkg/src/pkg > /dev/null
    COMMITCOUNT=`$GIT rev-list --count HEAD`
    logmsg "--- packaging"
    logcmd make check publish-pkgs \
        BUILDNUM=$BUILDNUM \
        PKGVERS_BRANCH=$BUILDNUM.1.$COMMITCOUNT \
        PKGSEND_OPTS="" \
        PKGPUBLISHER=$PKGPUBLISHER \
        PKGREPOTGT="" \
        PKGREPOLOC="$PKGSRVR" \
        || logerr "publish failed"
    popd > /dev/null
}

init
clone_source
build
package

if [ -z "$SKIP_PKG_DIFF" ]; then
    for pkg in $PKGLIST; do
        diff_latest $pkg
    done
fi

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
