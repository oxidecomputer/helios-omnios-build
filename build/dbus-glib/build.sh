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
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=dbus-glib
VER=0.110
PKG=system/library/libdbus-glib
SUMMARY="$PROG - GNOME GLib DBUS integration library"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="
    system/library/libdbus
    library/glib2
"

CONFIGURE_OPTS="
    --disable-fam
    --disable-dtrace
    --disable-tests
    GLIB_GENMARSHAL=/usr/bin/glib-genmarshal
"
CONFIGURE_OPTS_WS="
    DBUS_LIBS=-ldbus-1
    DBUS_GLIB_LIBS=\"-lglib-2.0 -lgobject-2.0 -lgio-2.0\"
"
CONFIGURE_OPTS_WS_32="
    DBUS_CFLAGS=\"-I/usr/include/dbus-1.0 -I/usr/lib/dbus-1.0/include\"
    DBUS_GLIB_CFLAGS=\"-I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include\"
"
CONFIGURE_OPTS_WS_64="
    DBUS_CFLAGS=\"-I/usr/include/dbus-1.0 -I/usr/lib/amd64/dbus-1.0/include\"
    DBUS_GLIB_CFLAGS=\"-I/usr/include/glib-2.0 -I/usr/lib/amd64/glib-2.0/include\"
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
