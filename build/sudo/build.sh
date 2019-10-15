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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=sudo
VER=1.8.28
PKG=security/sudo
SUMMARY="Authority delegation tool"
DESC="Provide limited super-user privileges to specific users"

CONFIGURE_OPTS_32+="
    --bindir=/usr/bin
    --sbindir=/usr/sbin
    --libexecdir=/usr/lib/sudo
"
CONFIGURE_OPTS_64+="
    --libexecdir=/usr/lib/sudo/amd64
"
CONFIGURE_OPTS="
    --with-ldap
    --with-project
    --with-rundir=/var/run/sudo
    --with-pam --with-pam-login
    --with-tty-tickets
    --without-insults
    --without-lecture
    --with-ignore-dot
    --with-bsm-audit
    --disable-pam-session
"

SKIP_LICENCES=Various
TESTSUITE_SED="
    /^libtool:/d
"

make_install64() {
    # This file will exist from the 32-bit 'make install' and so this
    # install will attempt to validate it and will fail because we aren't
    # running as root. Remove the file and let the 64-bit installation
    # re-create it.
    logcmd rm -f $DESTDIR/etc/sudoers
    make_install
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_isa_stub
VER=${VER//p/.}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
