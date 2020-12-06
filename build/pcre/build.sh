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

# Copyright 2011-2015 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=pcre
VER=8.44
PKG=library/pcre
SUMMARY="Perl-Compatible Regular Expressions"
DESC="The PCRE library is a set of functions that implement regular expression"
DESC+=" pattern matching using the same syntax and semantics as Perl 5"

CONFIGURE_OPTS="
	--localstatedir=/var
	--disable-static
	--enable-cpp
	--enable-rebuild-chartables
	--enable-utf8
	--enable-unicode-properties
	--enable-newline-is-any
	--disable-stack-for-recursion
	--enable-pcregrep-libz
	--enable-pcregrep-libbz2
	--with-posix-malloc-threshold=20
	--with-link-size=4
	--with-match-limit=10000000
	--with-pic
"
LDFLAGS+=" $SSPFLAGS"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
