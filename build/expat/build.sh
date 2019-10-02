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

PROG=expat
VER=2.2.9
PKG=library/expat
SUMMARY="XML parser library"
DESC="Fast streaming XML parser written in C"

CONFIGURE_OPTS_64+="
    --bindir=/usr/bin
"

TESTSUITE_SED="
    /^[^#]/d
"

save_function make_clean _make_clean
make_clean() {
    # As of expat 2.2.4, distclean removes the generated xmlwf.1
    # man page too so that it is re-generated during build using
    # docbook2X. We don't have docbook2X so preserve the file.
    [ -f doc/xmlwf.1~ ] || cp doc/xmlwf.1{,~}
    _make_clean
    [ -f doc/xmlwf.1 ] || cp doc/xmlwf.1{~,}
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
