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
#
# The ILLUMOSVER is the suffix of the tag gcc-4.4.4-<ILLUMOSVER>.
# It takes the form "il-N" for some number N.  These are announced to the
# illumos developer's list, and it is expected that OmniOSce will keep a
# copy at mirrors.omniosce.org, or local maintainers keep it whereever they
# keep their local mirrors.
#
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
set_arch 32

# Although we're building a 32-bit version of the compiler, gcc will take
# care of building 32 and 64-bit objects to support its toolchain. We need
# to unset the build flags and leave it to the gcc build system.
unset CFLAGS32 CFLAGS64
unset CPPFLAGS32 CPPFLAGS64
unset CXXFLAGS32 CXXFLAGS64
unset LDFLAGS32 LDFLAGS64

XFORM_ARGS="-D TRIPLET=$TRIPLET32 -D VER=$VER -D PREFIX=${PREFIX#/}"

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

HARDLINK_TARGETS="
    ${PREFIX/#\/}/bin/$TRIPLET32-gcc-$VER
    ${PREFIX/#\/}/bin/$TRIPLET32-c++
    ${PREFIX/#\/}/bin/$TRIPLET32-g++
"

export LD=/bin/ld
export LD_FOR_TARGET=$LD
export LD_FOR_HOST=$LD

CONFIGURE_OPTS_32="--prefix=/opt/gcc-${VER}"
CONFIGURE_OPTS="
    --host ${TRIPLET32}
    --build ${TRIPLET32}
    --target ${TRIPLET32}
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

init
download_source gcc44 ${PROG}-gcc-4.4.4-${ILLUMOSVER}
patch_source
prep_build
build

# For some reason, this gcc44 package doesn't properly push the LDFLAGS shown
# above into various subdirectories.  Use elfedit to fix it.
ESTRING="dyn:runpath /opt/gcc-${VER}/lib:%o"
logcmd elfedit -e "$ESTRING" $TMPDIR/$BUILDDIR/host-$TRIPLET32/gcc/cc1 \
    || logerr "elfedit cc1 failed"
logcmd elfedit -e "$ESTRING" $TMPDIR/$BUILDDIR/host-$TRIPLET32/gcc/cc1plus \
    || logerr "elfedit cc1plus failed"

make_package gcc.mog depends.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
