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
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=rsyslog
VER=8.2008.0
PKG=system/rsyslog
SUMMARY="rsyslog - the rocket-fast system for log processing."
DESC="A high-performance, modular syslog implementation."

FJSONVER=0.99.8
XFORM_ARGS+=" -DFJSON=$FJSONVER"

ESTRVER=0.1.11
XFORM_ARGS+=" -DESTR=$ESTRVER"

set_arch 64
set_standard XPG6

init
prep_build

#########################################################################
# Download and build a static dependencies

save_buildenv
# libfastjson does not provide ./configure
save_function configure64 _configure64
configure64() {
    run_autoreconf -fi
    _configure64 "$@"
}
CONFIGURE_OPTS="--disable-shared"

PATH=$GNUBIN:$PATH \
    build_dependency fastjson libfastjson-$FJSONVER $PROG/fastjson v$FJSONVER
build_dependency estr libestr-$ESTRVER $PROG/estr v$ESTRVER

restore_buildenv
save_function _configure64 configure64

export LIBFASTJSON_CFLAGS="-I$DEPROOT/usr/include/libfastjson"
export LIBFASTJSON_LIBS="-L$DEPROOT/usr/lib/$ISAPART64 -lfastjson"
export LIBESTR_CFLAGS="-I$DEPROOT/usr/include"
export LIBESTR_LIBS="-L$DEPROOT/usr/lib/$ISAPART64 -lestr"
addpath PKG_CONFIG_PATH64 $DEPROOT$PREFIX/lib/$ISAPART64/pkgconfig

#########################################################################

note -n "-- Building $PROG"

CONFIGURE_OPTS="
    --enable-klog
    --enable-inet
    --disable-libsystemd

    --disable-libgcrypt
    --disable-gnutls
    --enable-openssl
    --enable-gssapi-krb5

    --enable-imsolaris
    --enable-impstats

    --enable-omstdout
    --enable-omhttp
    --enable-omuxsock

    --enable-mail
    --disable-mysql

    --disable-generate-man-pages

    --enable-testbench
    --enable-imdiag
    --enable-extended-tests
"

# There is no need to install the plugins under amd64/
CONFIGURE_OPTS_64+="
    --libdir=$PREFIX/lib
    --libexecdir=$PREFIX/lib
"

# The testsuite output is quite noisy - clean it up
TESTSUITE_FILTER="(PASS|SKIP|FAIL|ERROR|TOTAL|summary|====)"

download_source $PROG $PROG $VER
patch_source
build
PATH=$GNUBIN:$PATH run_testsuite check
install_smf system rsyslog.xml rsyslog
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
