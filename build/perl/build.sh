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

# Copyright 2011-2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=perl
PKG=runtime/perl
VER=5.30.3
MAJVER=${VER%.*}
SUMMARY="Perl $MAJVER Programming Language"
DESC="A highly capable, feature-rich programming language"

set_arch 64

PREFIX=/usr/perl5/$MAJVER

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
"

HARDLINK_TARGETS="
    ${PREFIX#/}/bin/$PROG$VER
    ${PREFIX#/}/bin/${PROG}thanks
    ${PREFIX#/}/man/man1/${PROG}thanks.1
"

BUILD_DEPENDS_IPS="text/gnu-sed"

TESTSUITE_SED="
    /ExtUtils::Command/d
"

configure64() {
    logmsg "--- configure (64-bit)"
    logcmd $SHELL Configure \
        -des \
        -Dusethreads \
        -Duseshrplib \
        -Dusedtrace \
        -Dusemultiplicity \
        -Duselargefiles \
        -Duse64bitint \
        -Dmyhostname=localhost \
        -Umydomain \
        -Umyuname \
        -Dcf_by=omnios-builder \
        -Dcf_email=sa@omniosce.org \
        -Dcc=gcc \
        -Dld=/usr/ccs/bin/ld \
        -Doptimize=-O3 \
        -Dccflags="-D_LARGEFILE64_SOURCE -m64 -D_TS_ERRNO" \
        -Dldflags="-m64" \
        -Dlddlflags="-G -64" \
        -Dprefix=${PREFIX} \
        -Dvendorprefix=${PREFIX} \
        -Dbin=${PREFIX}/bin \
        -Dsitebin=${PREFIX}/bin \
        -Dvendorbin=${PREFIX}/bin \
        -Dscriptdir=${PREFIX}/bin \
        -Dsitescript=${PREFIX}/bin \
        -Dvendorscript=${PREFIX}/bin \
        -Dprivlib=${PREFIX}/lib \
        -Dsitelib=/usr/perl5/site_perl/$MAJVER \
        -Dvendorlib=/usr/perl5/vendor_perl/$MAJVER \
        -Dlibs="-lsocket -lnsl -lm -lc" \
        || logerr "--- Configure failed"

    logcmd sed -i '
        s/-fstack-protector-strong//g
        s/mydomain="\.undef"/mydomain="undef"/g
        /^lddlflags/s/-G -m64//
    ' config.sh
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
strip_install
run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
