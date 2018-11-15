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
#
#
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=jeos
PKG=incorporation/jeos/illumos-gate
VER=0.5.11
SUMMARY="OmniOS illumos incorporation"
DESC="Incorporation to constrain OmniOS illumos packages to the same release"

create_manifest_header()
{
    local mf=$1
    cat << EOM > $mf
set name=pkg.fmri value=pkg://@PKGPUBLISHER@/incorporation/jeos/illumos-gate@11,@SUNOSVER@-@PVER@
set name=pkg.depend.install-hold value=core-os.omnios
set name=pkg.description value="$DESC"
set name=pkg.summary value="$SUMMARY"
EOM
}

#depend fmri=SUNWcs@0.5.11,5.11-@PVER@ type=incorporate
add_constraints()
{
    local mf=$1
    local repo=$2

    [ ! -d "$repo" ] && logerr "--- Package repo does not exist."

    pkgrepo -s $repo list | sort -k2,2 | nawk -v pub=$PKGPUBLISHER '
        BEGIN {
            ops["o"] = "Obsolete"
            ops["r"] = "Renamed"
        }
        $3 in ops {
            printf("# %s: %s\n", ops[$3], $2)
            next
        }
        $1 == pub {
            pkg = $2
            ver = $3
            # 1.6.0-0.151023:20170728T111351Z
            i = index(ver, "-")
            if (i) ver = substr(ver, 1, i - 1)
            printf("depend fmri=%s@%s,5.11-@PVER@ type=incorporate\n",
                pkg, ver)
        }' | fgrep -v -f $SRCDIR/illumos-gate.exclude >> $mf
}

publish_pkg()
{
    local pmf=$1

    [ "`cat $pmf | wc -l`" -lt 300 ] && logerr "Short file $pmf"

    publish_manifest $PKG $pmf
}

init
prep_build
check_for_prebuilt 'packages/i386/nightly-nd/repo.redist/'
pkgrepo=$PREBUILT_ILLUMOS/packages/i386/nightly-nd/repo.redist

manifest=$TMPDIR/$PKGE.p5m
create_manifest_header $manifest
add_constraints $manifest $pkgrepo

publish_pkg $manifest
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
