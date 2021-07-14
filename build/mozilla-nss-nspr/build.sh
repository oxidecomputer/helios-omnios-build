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
# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=nss
VER=3.65
# Include NSPR version since we're downloading a combined tarball.
NSPRVER=4.30
# But set BUILDDIR to just be the NSS version.
set_builddir "$PROG-$VER"
PKG=$PROG ##IGNORE##
SUMMARY="Overridden for each package below"
DESC="$SUMMARY"

DIST32="`uname -sri | sed 's/ //; s/ /_/'`_gcc_OPT.OBJ"
DIST64="${DIST32/gcc_OPT/gcc_64_OPT}"

BUILD_DEPENDS_IPS="library/nspr/header-nspr"

set_ssp none
# required for getopt
set_standard XPG6

CTF_FLAGS+=" -s"

# nspr/nss produces lots of runtime warnings that we cannot easily resolve.
SKIP_RTIME_CHECK=1

MAKE_ARGS="
    -C nss
    BUILD_OPT=1
    NS_USE_GCC=1
    NO_MDUPDATE=1
    USE_MDUPDATE=
    NSDISTMODE=copy
    NSS_USE_SYSTEM_SQLITE=1
    NSS_ENABLE_WERROR=0
    NSS_DISABLE_GTESTS=1
    nss_build_all
"
MAKE_ARGS_WS_32="
    XCFLAGS=\"$CTF_CFLAGS $CFLAGS32 $CFLAGS\"
    LDFLAGS=\"$LDFLAGS32 $LDFLAGS\"
"
MAKE_ARGS_WS_64="
    USE_64=1
    XCFLAGS=\"$CTF_CFLAGS $CFLAGS64 $CFLAGS\"
    LDFLAGS=\"$LDFLAGS64 $LDFLAGS\"
"

NSS_LIBS="libfreebl3.so libnss3.so libnssckbi.so libnssdbm3.so
          libnssutil3.so libsmime3.so libsoftokn3.so libssl3.so"
NSS_BINS="certutil cmsutil crlutil derdump modutil pk12util signtool
          signver ssltap vfychain vfyserv"
NSS_MANS=`echo $NSS_BINS | sed -E 's/\<([a-z]*)\>/\1.1/g'`

NSPR_LIBS="libnspr4.so libplc4.so libplds4.so"

CLEANED=0
make_clean() {
    ((CLEANED == 0)) && logcmd rm -rf dist
    CLEANED=1
}

configure32() {
    export MAKE_ARGS_WS="$MAKE_ARGS_WS_32"
}

configure64() {
    export MAKE_ARGS_WS="$MAKE_ARGS_WS_64"
}

make_install32() { :; }

make_install64() {
    typeset dist=$TMPDIR/$BUILDDIR/dist
    typeset dist32=$dist/$DIST32
    typeset dist64=$dist/$DIST64

    logcmd mkdir $DESTDIR/$PREFIX
    pushd $DESTDIR/$PREFIX >/dev/null || logerr "pushd"

    set -eE; trap 'logerr Installation failed at $BASH_LINENO' ERR

    logcmd mkdir -p bin include/mps lib/mps/$ISAPART64 share/man/man1
    logcmd rsync -a $dist64/include/ include/mps/
    logcmd rsync -a $dist/public/nss/ include/mps/nss/
    logcmd rsync -a $dist/public/dbm/ include/mps/nss/
    logcmd rsync -a $dist32/lib/ lib/mps/
    logcmd rsync -a $dist64/lib/ lib/mps/$ISAPART64/
    logcmd rsync -a $dist/../nss/doc/nroff/ share/man/man1/

    ( cd $dist64/bin; cp $NSS_BINS $OLDPWD/bin/ ) >/dev/null
    for b in bin/*; do
        logcmd elfedit -e "dyn:runpath $PREFIX/lib/mps/$ISAPART64" $b
    done

    # There is no provided nss.pc file, and the nspr.pc doesn't account for
    # the alternate library path in OmniOS; we need to synthesise them.
    logcmd mkdir -p lib/pkgconfig/$ISAPART64
    for c in nss nspr; do
        sed < $SRCDIR/files/$c.pc > lib/pkgconfig/$c.pc "
            s/__NSSVER__/$VER/g
            s/__NSPRVER__/$NSPRVER/g
        "
        sed < lib/pkgconfig/$c.pc > lib/pkgconfig/$ISAPART64/$c.pc "
            /^libdir=/s^\$^/$ISAPART64^
        "
    done

    set +eE; trap - ERR

    popd >/dev/null
}

init
download_source $PROG $PROG "$VER-with-nspr-$NSPRVER"
patch_source
prep_build
build

###########################################################################

PKG=system/library/mozilla-nss/header-nss
SUMMARY="Network Security Services Headers"
DESC="$SUMMARY"

manifest_start $TMPDIR/manifest.nss.header
manifest_add_dir $PREFIX/include/mps/nss
manifest_add $PREFIX/lib/pkgconfig nss.pc
manifest_add $PREFIX/lib/pkgconfig/$ISAPART64 nss.pc
manifest_finalise $PREFIX

make_package -seed $TMPDIR/manifest.nss.header nss.mog

###########################################################################

PKG=system/library/mozilla-nss
SUMMARY="Network Security Services Libraries/Utilities"
DESC="$SUMMARY"

manifest_start $TMPDIR/manifest.nss
manifest_add $PREFIX/lib/mps $NSS_LIBS
manifest_add $PREFIX/lib/mps/$ISAPART64 $NSS_LIBS
manifest_add $PREFIX/bin $NSS_BINS
manifest_add $PREFIX/share/man/man1 $NSS_MANS
manifest_finalise $PREFIX

make_package -seed $TMPDIR/manifest.nss nss.mog

###########################################################################

PKG=library/nspr/header-nspr
VER=$NSPRVER
SUMMARY="Netscape Portable Runtime Headers"
DESC="$SUMMARY"

manifest_start $TMPDIR/manifest.nspr.header
manifest_add_dir $PREFIX/include/mps md obsolete private
manifest_add $PREFIX/lib/pkgconfig nspr.pc
manifest_add $PREFIX/lib/pkgconfig/$ISAPART64 nspr.pc
manifest_finalise $PREFIX

make_package -seed $TMPDIR/manifest.nspr.header nspr.mog

###########################################################################

PKG=library/nspr
SUMMARY="Netscape Portable Runtime"
DESC="$SUMMARY"

manifest_start $TMPDIR/manifest.nspr
manifest_add $PREFIX/lib/mps $NSPR_LIBS
manifest_add $PREFIX/lib/mps/$ISAPART64 $NSPR_LIBS
manifest_finalise $PREFIX

make_package -seed $TMPDIR/manifest.nspr nspr.mog

###########################################################################

clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
