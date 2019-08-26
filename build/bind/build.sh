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

PROG=bind
VER=9.11.10
PKG=network/dns/bind
SUMMARY="BIND DNS tools"
DESC="Client utilities for DNS lookups"

# This package ships private shared libraries in $PREFIX/lib/dns that are only
# provided for use by the client utilities. We can therefore build everything
# as 64-bit only and avoid shipping the include files, python modules and
# library man pages (see local.mog)
set_arch 64

SKIP_LICENCES="*"

CONFIGURE_OPTS="
    --libdir=$PREFIX/lib/dns
    --bindir=$PREFIX/sbin
    --localstatedir=/var
    --with-libtool
    --with-openssl
    --enable-threads=yes
    --enable-devpoll=yes
    --enable-fixed-rrset
    --disable-getifaddrs
    --enable-shared
    --disable-static
    --without-python
    --with-zlib=/usr
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
strip_install
VER=${VER//-P/.}
VER=${VER//-W/.}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
