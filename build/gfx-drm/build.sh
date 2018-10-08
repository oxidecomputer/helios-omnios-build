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
# Copyright 2018 Thomas Merkel
#

. ../../lib/functions.sh

PROG=gfx-drm
PKG=driver/graphics/agpgart
PKG=driver/graphics/drm
VER=0.152
DASHREV=152
SUMMARY="DRM kernel modules"
DESC="Collection of kernel modules that allow programs like the Xorg server "
DESC+="to operate hardware-accelerated graphics cards."

BUILDARCH=64

# Respect environmental overrides for these to ease development.
: ${GFX_DRM_SOURCE_REPO:=$GITHUB/gfx-drm}
: ${GFX_DRM_SOURCE_BRANCH:=r$RELVER}

init
BUILDDIR=$PROG-$VER
WORKDIR=$TMPDIR/$BUILDDIR/$PROG
DESTDIR=$WORKDIR/proto/root_i386

clone_source() {
    clone_github_source $PROG \
        "$GFX_DRM_SOURCE_REPO" "$GFX_DRM_SOURCE_BRANCH" "$GFX_DRM_CLONE"

    GITREV=`$GIT -C $WORKDIR log -1  --format=format:%at`
    COMMIT=`$GIT -C $WORKDIR log -1  --format=format:%h`
    REVDATE=`echo $GITREV | gawk '{ print strftime("%c %Z",$1) }'`
    VERHUMAN="${COMMIT:0:7} from $REVDATE"
}

pre_build() {
    logmsg "Providing env.sh script based on myenv.sh"
    pushd $WORKDIR > /dev/null
    PVER="$RELVER.$DASHREV"
    (
        sed < myenv.sh "
          s|^export CODEMGR_WS=.*|export CODEMGR_WS=$WORKDIR|
          s|^export NIGHTLY_OPTIONS=.*|export NIGHTLY_OPTIONS=\"-Dprnl\"|
          s|^export VERSION=.*|export VERSION=\"$PVER\"|
          s|^export ONNV_BUILDNUM=.*|export ONNV_BUILDNUM=\"$RELVER\"|
        "
        echo export PKGPUBLISHER=$PKGPUBLISHER
        echo export SUPPRESSPKGDEP=true
        echo export PKGVERS_BRANCH=$PVER
    ) > env-d.sh
    sed < env-d.sh > env.sh '
        /^export ROOT=/s/"$/-nd"/
    '
    popd > /dev/null
}

build() {
    logmsg "Building AGP GART and DRM Kernel Drivers"
    pushd $WORKDIR > /dev/null
    dirs="tools uts cmd/devfsadm cmd/mdb man/man7d man/man7i"
    logmsg "--- Building"
    for dir in $dirs; do
        logmsg " -- $dir"
        logmsg "  - Non-debug"
        logcmd env -i /opt/onbld/bin/bldenv $WORKDIR/env.sh \
            "cd $WORKDIR/usr/src/$dir && dmake install" \
            || logerr "$dir build failed"
        logcmd env -i /opt/onbld/bin/bldenv $WORKDIR/env.sh \
            "cd $WORKDIR/usr/src/$dir && dmake clobber"
        logmsg "  - Debug"
        logcmd env -i /opt/onbld/bin/bldenv -d $WORKDIR/env-d.sh \
            "cd $WORKDIR/usr/src/$dir && dmake install" \
            || logerr "$dir build failed"
    done
    popd > /dev/null
}

make_package() {
    pushd $WORKDIR/usr/src/pkg/manifests
    logcmd rm -f {system-header-*,system-test-*,x11-*-libdrm}.mf
    popd

    logmsg "Packages for driver/graphics/agpgart and driver/graphics/drm"
    pushd $WORKDIR > /dev/null
    logcmd env -i /opt/onbld/bin/bldenv $WORKDIR/env.sh \
        "cd $WORKDIR/usr/src/pkg && make install" \
        || logerr "NON-DEBUG package build failed"
    logcmd env -i /opt/onbld/bin/bldenv -d $WORKDIR/env-d.sh \
        "cd $WORKDIR/usr/src/pkg && make install" \
        || logerr "DEBUG package build failed"
    popd > /dev/null
}

push_pkgs() {
    logmsg "Pushing $PROG pkgs to $PKGSRVR..."
    logcmd pkgmerge -d $PKGSRVR \
        -s debug.illumos=false,$WORKDIR/packages/i386/nightly-nd/repo.drm \
        -s debug.illumos=true,$WORKDIR/packages/i386/nightly/repo.drm \
        || logerr "push failed"
}

clone_source
pre_build
build
make_package
push_pkgs
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
