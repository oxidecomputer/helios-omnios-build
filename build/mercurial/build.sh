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

PROG=mercurial
VER=5.1.2
PKG=developer/versioning/mercurial
SUMMARY="Mercurial source control management"
DESC="Free, distributed source control management tool"

# Mercurial currently has beta support for Python 3 and use of Python 2.7 is
# recommended for the best experience.
# See https://www.mercurial-scm.org/wiki/Python3 for more on Mercurial's
# Python 3 support.

set_python_version $PYTHON2VER

RUN_DEPENDS_IPS="web/curl library/security/openssl"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
