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
# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.
#
. ../../../lib/build.sh

PKG=library/python-3/prettytable-310
PROG=prettytable
inherit_ver python39/prettytable
SUMMARY="Simple tabular data display"
DESC="prettytable - A simple Python library for easily displaying tabular "
DESC+="data in a visually appealing ASCII table format."

. $SRCDIR/../common.sh

RUN_DEPENDS_IPS+=" library/python-$PYMVER/wcwidth-$SPYVER"

init
download_source pymodules/$PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
