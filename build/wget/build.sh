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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=wget
VER=1.20.3
PKG=web/wget
SUMMARY="GNU Wget"
DESC="Retrieving files using HTTP, HTTPS, FTP and FTPS "
DESC+="the most widely-used Internet protocols"

RUN_DEPENDS_IPS="library/libidn web/ca-bundle"
BUILD_DEPENDS_IPS+="
    developer/lexer/flex
    library/pcre2
"

# required to run the test-suite
TEST_DEPENDS_PERLMOD="
    HTTP::Daemon
    IO::Socket::SSL
"

set_arch 64

CONFIGURE_OPTS="
    --with-ssl=openssl
    --mandir=$PREFIX/share/man
    POD2MAN=/usr/perl5/bin/pod2man
"

TESTSUITE_FILTER='^[A-Z#][A-Z ]'

download_perl_deps() {
    # download and build perl dependencies
    for dep in $TEST_DEPENDS_PERLMOD; do
        note "-- Building dependency $dep"
        curl -L https://cpanmin.us | perl - -l $TMPDIR/_deproot \
            -M https://cpan.metacpan.org -n $dep
    done
}

init
download_source $PROG $PROG $VER
patch_source
run_autoreconf
prep_build
build
[ -z "$SKIP_TESTSUITE" ] && download_perl_deps
PERL5LIB=$TMPDIR/_deproot/lib/perl5 run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
