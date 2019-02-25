#!/usr/bin/bash
#
# {{{ CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END }}}

#
# Copyright 2011-2015 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=pcre
VER=8.43
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
