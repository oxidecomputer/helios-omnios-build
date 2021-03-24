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
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# }}}
#
# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=openssl
PKG=library/security/openssl
SUMMARY="Cryptography and SSL/TLS Toolkit"
DESC="A toolkit for Secure Sockets Layer and Transport Layer protocols "
DESC+="and general purpose cryptographic library"

# Use the version of the openssl 1.1 package for this meta package
inherit_ver openssl build-1.1.sh

create_manifest()
{
    local mf=$1
    local ver=$VER
    convert_version ver
    cat << EOM > $mf
set name=pkg.fmri \
    value=pkg://@PKGPUBLISHER@/library/security/openssl@$ver,@SUNOSVER@-@PVER@
set name=pkg.summary value="$SUMMARY"
set name=pkg.description value="$DESC"
set name=pkg.human-version value="$VER"

depend fmri=library/security/openssl-11 type=require

#
# To aid transition from the old openssl package which combined both
# OpenSSL 1.0.2 and 1.1.1 together, include a dependency on openssl-10.
# This should remain in place until after r151038 is released, to ensure that
# upgraded systems retain the old lib{ssl,crypto}.so.1.0.0 libraries.
# This should be removed in r151039 so that default installations from
# r151040 onwards will not include openssl 1.0 (but the package will be
# available for anyone who wishes to install it manually, and upgraders will
# not lose it).
#
depend fmri=library/security/openssl-10 type=require facet.openssl.10=true

EOM
}

init
prep_build

manifest=$TMPDIR/$PKGE.p5m
create_manifest $manifest
publish_manifest $PKG $manifest
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
