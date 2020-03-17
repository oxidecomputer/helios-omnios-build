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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

BUILD_DEPENDS_IPS="
    developer/acpi
    developer/nasm
"

PROG=uefi-edk2
PKG=system/bhyve/firmware
VER=20190904
SUMMARY="UEFI-EDK2(+CSM) firmware for bhyve"
DESC="$SUMMARY"

# Respect environmental overrides for these to ease development.
: ${EDK2_SOURCE_REPO:=$GITHUB/$PROG}
: ${EDK2_LEGACY_BRANCH:=master}
: ${EDK2_SOURCE_BRANCH:=edk2-stable201903}

# The UEFI 2.70 firmware does not work with PCI pass-through so we continue
# to set the links so that 2.40 is the default for now.
XFORM_ARGS+=" -D UEFIVER=2.40 -D CSMVER=2.40"

setup_env() {

    case $1 in
        $EDK2_LEGACY_BRANCH)
            UPKGPREFIX=Bhyve
            set_gccver 4.4.4
            unset PYTHON3_ENABLE
            PKGSUFFIX=-2.40
            BUILD_CSM=1
            EXTRA_BUILD_ARGS=
            ;;
        $EDK2_SOURCE_BRANCH)
            UPKGPREFIX=Ovmf
            set_gccver $DEFAULT_GCC_VER
            export PYTHON3_ENABLE=TRUE
            PKGSUFFIX=-2.70
            BUILD_CSM=0
            EXTRA_BUILD_ARGS="-DHTTP_BOOT_ENABLE=TRUE"
            ;;
    esac

    MAKE_ARGS="
            AS=/usr/bin/gas
            AR=/usr/bin/gar
            LD=/usr/bin/gld
            OBJCOPY=/usr/bin/gobjcopy
            CC=$GCC BUILD_CC=$GCC
            CXX=$GXX BUILD_CXX=$GXX
    "

    export OOGCC_BIN=$GCCPATH/bin/
}

export IASL_PREFIX=/usr/sbin/
export NASM_PREFIX=/usr/bin/

edksetup() {
    source edksetup.sh
}

cleanup() {
    logmsg "-- Cleaning source tree"

    logcmd gmake $MAKE_ARGS HOST_ARCH=X64 ARCH=X64 -C BaseTools clean
    rm -rf Build Conf/{target,build_rule,tools_def}.txt Conf/.cache 2>/dev/null
}

build_tools() {
    logmsg "-- Building tools"

    # The code isn't able to detect the build architecture - it doesn't
    # expect `uname -m` to return `i86pc`
    logcmd gmake $MAKE_ARGS HOST_ARCH=X64 ARCH=X64 -C BaseTools \
        || logerr "--- BaseTools build failed"
}

build() {
    [ "$1" = "-csm" ] && csm=1 || csm=0

    BUILD_ARGS="-DDEBUG_ON_SERIAL_PORT=TRUE -DFD_SIZE_2MB"
    [ $csm -eq 1 ] && BUILD_ARGS+=" -DCSM_ENABLE=TRUE"
    BUILD_ARGS+=" $EXTRA_BUILD_ARGS"

    export BUILD_ARGS

    for mode in RELEASE DEBUG; do

        logmsg "-- Building $mode firmware"

        case $mode in
            RELEASE)    dport=0x2f8; level=CRIT ;;
            DEBUG)      dport=0x3f8; level=INFO ;;
        esac

        dir=${UPKGPREFIX}Pkg
        dec=$dir/${UPKGPREFIX}Pkg.dec
        dsc=$dir/${UPKGPREFIX}PkgX64.dsc

        logcmd sed -i "/PcdDebugIoPort|0x[0-9A-Fa-f]/s/0x[0-9A-Fa-f]*/$dport/" \
            $dec || logerr "sed $dec"
        logcmd sed -i "/DEBUG_PORT=0x/s/0x.*/$dport/" \
            $dir/Csm/BhyveCsm16/GNUmakefile || logerr "sed GNUmakefile"
        logcmd sed -i "/DebugLevel = DBG/s/DBG_.*/DBG_$level;/" \
            $dir/Csm/BhyveCsm16/Printf.c || logerr "sed Printf.c"

        if [ $csm -eq 1 ]; then
            logmsg "-- Building compatibility support module (CSM)"
            logcmd gmake $MAKE_ARGS -C $dir/Csm/BhyveCsm16/ clean all \
                || logerr "--- CSM build failed"
        fi

        logcmd `which build` \
            -t OOGCC -a X64 -b $mode \
            -p $dsc \
            $BUILD_ARGS || logerr "--- $mode build failed"
    done
}

install() {
    suffix="$1"
    logcmd mkdir -p $DESTDIR/usr/share/bhyve/firmware
    [ -f $DESTDIR/LICENCE ] || cp OvmfPkg/License.txt $DESTDIR/LICENCE
    for mode in RELEASE DEBUG; do
        logcmd cp Build/${UPKGPREFIX}X64/${mode}_OOGCC/FV/${UPKGPREFIX^^}.fd \
            $DESTDIR/usr/share/bhyve/firmware/BHYVE_$mode$suffix$PKGSUFFIX.fd \
            || logerr "firmware copy failed"
    done
}

######################################################################
# The default release branch

init
prep_build

for branch in $EDK2_SOURCE_BRANCH $EDK2_LEGACY_BRANCH; do

    [ -n "$DEPVER" -a "$DEPVER" != $branch ] && continue

    # branch names can contain '/', create a copy with these replaced
    # that can be used for directory/file names.
    sbranch="${branch//\//_}"

    note -n "-- Building firmware from $branch branch"

    clone_github_source $sbranch/ "$EDK2_SOURCE_REPO" "$branch" "$EDK2_CLONE"

    (
        setup_env $branch

        pushd "$TMPDIR/$BUILDDIR/$sbranch" >/dev/null || logerr "Cannot pushd"

        logmsg "-- Updating git submodules"
        logcmd git submodule update --init --progress .

        cleanup

        build_tools
        edksetup

        if [[ -z "$FLAVOR" || "$FLAVOR" = *UEFI* ]]; then
            # Build UEFI firmware
            note -n "UEFI Firmware"
            build
            install
        fi

        if [ $BUILD_CSM -ne 0 ] && [[ -z "$FLAVOR" || "$FLAVOR" = *CSM* ]]; then
            # Build UEFI+CSM firmware
            note -n "UEFI+CSM Firmware"
            build -csm
            install _CSM
        fi

        popd >/dev/null
    )
done

make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
