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

# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=release
VER=0.5.11
PKG=release/name
SUMMARY="Helios release information"
DESC="Helios /etc/release and /etc/os-release files"

# Update the following line with the current release suffix
RELSUFFIX=

RELEASE=${RELVER}${RELSUFFIX}
RELDATE="`date +%Y.%m.%d`"
RELNUM=${RELVER}
RELREV=0

if [[ "$RELEASE" = *[a-z] ]]; then
    alpha="`echo "$RELEASE" | sed 's/[0-9]//g'`"
    while [ ${#alpha} -gt 0 ]; do
        ((RELREV *= 26))
        ch="`ord26 ${alpha:0:1}`"
        ((RELREV += ch))
        alpha="${alpha:1}"
    done
fi

DASHREV=$RELREV

XFORM_ARGS="
    -DRELEASE=$RELEASE -DRELNUM=$RELNUM -DRELDATE=$RELDATE -DRELREV=$RELREV
"

build() {
    logmsg "Generating release files"

    pushd $DESTDIR >/dev/null

    logcmd mkdir -p etc || logerr "-- mkdir failed"

    cat <<- EOM > etc/release
Oxide Helios $RELEASE
	EOM

    cat <<- EOM > etc/os-release
NAME="Helios"
PRETTY_NAME="Oxide Helios $RELEASE"
CPE_NAME="cpe:/o:oxide:helios:$RELNUM:$RELREV"
ID=helios
VERSION=$RELEASE
VERSION_ID=$RELEASE
BUILD_ID=$RELNUM.$RELREV.$RELDATE
HOME_URL="$HOMEURL/"
SUPPORT_URL="$HOMEURL/"
BUG_REPORT_URL="https://github.com/oxidecomputer/helios/issues/new"
	EOM

    popd >/dev/null
}

init
prep_build
build
make_package release.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
