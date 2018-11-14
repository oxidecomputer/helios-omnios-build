#!/usr/bin/bash

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

. ../../lib/functions.sh

PROG=jeos
PKG=incorporation/jeos/omnios-userland
VER=0.5.11
SUMMARY="OmniOS userland incorporation"
DESC="Incorporation to constrain OmniOS userland packages to the same release"

create_manifest_header()
{
    local mf=$1
    cat << EOM > $mf
set name=pkg.fmri \\
  value=pkg://@PKGPUBLISHER@/incorporation/jeos/omnios-userland@11,@SUNOSVER@-@PVER@
set name=pkg.depend.install-hold value=core-os.omnios
set name=pkg.summary value="$SUMMARY"
set name=pkg.description value="$DESC"
EOM
}

add_constraints()
{
    local cmf=$1
    local src=$2

    egrep -v '^ *$|^#' $src | while read pkg ver dash; do
        if [ -z "$pkg" -o -z "$ver" ]; then
            logerr "Bad package line, $pkg $ver"
        fi
        [ -z "$dash" ] && dash=0
        [ "$dash" = "-" ] && dash= || dash=".$dash"
        echo "depend facet.version-lock.$pkg=true"\
            "fmri=$pkg@$ver,5.11-@RELVER@$dash type=incorporate" \
            >> $cmf
    done
}

init
prep_build

manifest=$TMPDIR/$PKGE.p5m
create_manifest_header $manifest
add_constraints $manifest $SRCDIR/omnios-userland.pkg

publish_manifest $PKG $manifest
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
