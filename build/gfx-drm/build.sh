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
PKG=system/header/header-agp
PKG=system/header/header-drm
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
            s|^export NIGHTLY_OPTIONS=.*|export NIGHTLY_OPTIONS='-Dprnl'|
            /^export VERSION=/d
            /^export ONNV_BUILDNUM=/d
        "
        cat <<-EOM
			export VERSION=$PVER
			export ONNV_BUILDNUM=$RELVER
			export PKGPUBLISHER=$PKGPUBLISHER
			export SUPPRESSPKGDEP=true
			export PKGVERS_BRANCH=$PVER
			export GNUC_ROOT=/opt/gcc-4.4.4
		EOM
    ) > env-d.sh
    sed < env-d.sh > env.sh '
        /^export ROOT=/s/"$/-nd"/
    '
    popd > /dev/null

    BLDENV=$WORKDIR/tools/bldenv
    logcmd chmod u+x $BLDENV || logerr "Cannot change bldenv mode"
    export BLDENV
}

build() {
    logmsg "Building AGP GART and DRM Kernel Drivers"
    pushd $WORKDIR > /dev/null

    logmsg "--- Preparing (non-DEBUG)"
    logcmd env -i $BLDENV $WORKDIR/env.sh \
        "cd $WORKDIR/usr/src && dmake setup" \
        || logerr "$dir build failed"
    logmsg "--- Preparing (DEBUG)"
    logcmd env -i $BLDENV $WORKDIR/env-d.sh \
        "cd $WORKDIR/usr/src && dmake setup" \
        || logerr "$dir build failed"

    logmsg "--- Building"
    dirs="uts cmd/devfsadm cmd/mdb man/man7d man/man7i"
    for dir in $dirs; do
        logmsg " -- $dir"
        logmsg "  - Non-debug"
        logcmd env -i $BLDENV $WORKDIR/env.sh \
            "cd $WORKDIR/usr/src/$dir && dmake install" \
            || logerr "$dir build failed"
        logmsg "  - Debug"
        logcmd env -i $BLDENV -d $WORKDIR/env-d.sh \
            "cd $WORKDIR/usr/src/$dir && dmake clobber install" \
            || logerr "$dir build failed"
    done
    popd > /dev/null
}

make_package() {
    pushd $WORKDIR/usr/src/pkg/manifests
    logcmd rm -f {system-test-*,x11-*-libdrm}.mf
    popd

    logmsg "Packages for agpgart and drm"
    pushd $WORKDIR > /dev/null
    logcmd env -i $BLDENV $WORKDIR/env.sh \
        "cd $WORKDIR/usr/src/pkg && make install" \
        || logerr "NON-DEBUG package build failed"
    logcmd env -i $BLDENV -d $WORKDIR/env-d.sh \
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
    if [ -z "$BATCH" -a -z "$SKIP_PKG_DIFF" ]; then
        diff_package driver/graphics/agpgart@0.5.11,$SUNOSVER-$RELVER.$DASHREV
        diff_package driver/graphics/drm@0.5.11,$SUNOSVER-$RELVER.$DASHREV
        diff_package system/header/header-agp@0.5.11,$SUNOSVER-$RELVER.$DASHREV
        diff_package system/header/header-drm@0.5.11,$SUNOSVER-$RELVER.$DASHREV
    fi
}

clone_source
pre_build
build
make_package
push_pkgs
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
