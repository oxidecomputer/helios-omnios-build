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
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=gcc
VER=4.4.4
ILLUMOSVER=il-4
VERHUMAN="${VER}-${ILLUMOSVER}"
PKG=developer/gcc44
SUMMARY="gcc ${VER} (illumos il-4_4_4 branch, tag gcc-4.4.4-${ILLUMOSVER})"
DESC="GCC with the patches from Codesourcery/Sun Microsystems used in the "
DESC+="3.4.3 and 4.3.3 shipped with Solaris."

PREFIX=/opt/gcc-${VER}

set_builddir "${PROG}-gcc-4.4.4-${ILLUMOSVER}"

# Build gcc44 with itself...
set_gccver 4.4.4
set_ssp none
set_arch 32

# Although we're building a 32-bit version of the compiler, gcc will take
# care of building 32 and 64-bit objects to support its toolchain. We need
# to unset the build flags and leave it to the gcc build system.
unset CFLAGS32 CFLAGS64
unset CPPFLAGS32 CPPFLAGS64
unset CXXFLAGS32 CXXFLAGS64
unset LDFLAGS32 LDFLAGS64

XFORM_ARGS="-D TRIPLET=$TRIPLET32 -D VER=$VER -D PREFIX=${PREFIX#/}"
BMI_EXPECTED=1

BUILD_DEPENDS_IPS="
    developer/gcc44/libgmp-gcc44
    developer/gcc44/libmpfr-gcc44
    developer/gcc44/libmpc-gcc44
    developer/gnu-binutils
    developer/linker
    system/library/gcc-runtime
"
RUN_DEPENDS_IPS="
    $BUILD_DEPENDS_IPS
    system/library/c-runtime
"

reset_configure_opts

export LD=/bin/ld
export LD_FOR_TARGET=$LD
export LD_FOR_HOST=$LD
ARCH=$TRIPLET32

HARDLINK_TARGETS="
    ${PREFIX/#\/}/bin/$ARCH-gcc-$VER
    ${PREFIX/#\/}/bin/$ARCH-c++
    ${PREFIX/#\/}/bin/$ARCH-g++
"


CONFIGURE_OPTS_32="--prefix=/opt/gcc-${VER}"
CONFIGURE_OPTS="
    --host ${ARCH}
    --build ${ARCH}
    --target ${ARCH}
    --with-boot-ldflags=-R/opt/gcc-${VER}/lib
    --with-gmp=/opt/gcc-${VER}
    --with-mpfr=/opt/gcc-${VER}
    --with-mpc=/opt/gcc-${VER}
    --enable-languages=c,c++
    --without-gnu-ld --with-ld=/bin/ld
    --with-as=/usr/bin/gas --with-gnu-as
    --with-build-time-tools=/usr/gnu/$TRIPLET64/bin
"
LDFLAGS32="-R/opt/gcc-${VER}/lib"
export LD_OPTIONS="-zignore -zcombreloc -Bdirect -i"

# If the selected compiler is the same version as the one we're building
# then the three-stage bootstrap is unecessary and some build time can be
# saved.
[ -z "$FORCE_BOOTSTRAP" ] \
    && [ "`gcc -v 2>&1 | nawk '/^gcc version/ { print $3 }'`" = "$VER" ] \
    && CONFIGURE_OPTS+=" --disable-bootstrap" \
    && logmsg "--- disabling bootstrap"

fix_runpath() {
    # For some reason, this gcc44 package doesn't properly push the LDFLAGS
    # shown above into various subdirectories.  Use elfedit to fix it.
    ESTRING="dyn:runpath /opt/gcc-${VER}/lib:%o"
    logcmd elfedit -e "$ESTRING" $TMPDIR/$BUILDDIR/host-$ARCH/gcc/cc1 \
        || logerr "elfedit cc1 failed"
    logcmd elfedit -e "$ESTRING" $TMPDIR/$BUILDDIR/host-$ARCH/gcc/cc1plus \
        || logerr "elfedit cc1plus failed"
}

tests() {
    # A specific test to ensure that thread-local storage is properly
    # detected and is not being emulated.
    egrep -s gcc_cv_have_cc_tls=yes \
        $TMPDIR/$BUILDDIR/$ARCH/libgcc/config.log \
        || logerr "Emulated TLS is enabled"

    [ -n "$SKIP_TESTSUITE" ] && return
    if [ -z "$BATCH" ] && ! ask_to_testsuite; then
        return
    fi

    export GUILE_AUTO_COMPILE=0
    export PATH+=:$OOCEBIN
    # The tests can be run in parallel - we sort them afterwards for consistent
    # results.
    MAKE_TESTSUITE_ARGS+=" $MAKE_JOBS"
    # Some gcc tests (e.g. limits-exprparen.c) need a larger stack
    ulimit -Ss 16385
    # Lots of tests create core files via assertions
    ulimit -c 0
    # This causes the testsuite to be run twice, once with no additional
    # options (see the leading , in the {} expression), and once with
    # -msave-args
    MAKE_TESTSUITE_ARGS+=" RUNTESTFLAGS=--target_board=unix/\{,-msave-args\}"
    # If not in batch mode, we've already asked whether this should be run
    # above, so set BATCH
    BATCH=1 run_testsuite "check check-target" "" build.log.testsuite
    pushd $TMPDIR/$BUILDDIR >/dev/null
    # Sort the test results in the individual summary files
    find $TMPDIR/$BUILDDIR -name '*.sum' -type f | while read s; do
        cp $s $s.orig
        nawk '
            /^Running target unix/ { sorting = 1; print; next }
            /Summary .*===$/ { close("sort -k2"); sorting = 0; print; next }
            sorting { print | "sort -k2" }
            # The version lines include the build path
            /  version / { next }
            { print }
        ' < $s.orig > $s
    done
    make_param mail-report.log
    cat mail-report.log > $SRCDIR/testsuite.log.detail
    egrep ' Summary (for .*)?===$|^#' mail-report.log > $SRCDIR/testsuite.log
    popd >/dev/null
}

init
download_source gcc44 ${PROG}-gcc-4.4.4-${ILLUMOSVER}
patch_source
prep_build
build -noctf
fix_runpath
tests
make_package gcc.mog depends.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
