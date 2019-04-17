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

# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=pcre2
VER=10.33
PKG=library/pcre2
SUMMARY="Perl-Compatible Regular Expressions, version 2"
DESC="The PCRE library is a set of functions that implement regular expression"
DESC+=" pattern matching using the same syntax and semantics as Perl 5"

CONFIGURE_OPTS="
	--localstatedir=/var
	--disable-static
	--enable-rebuild-chartables
	--enable-newline-is-any
	--disable-stack-for-recursion
	--with-link-size=4
	--with-match-limit=10000000
	--with-pic
"

init
download_source pcre $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
