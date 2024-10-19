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
# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/build.sh
. common.sh

PKG=system/library/g++-runtime
PROG=libstdc++
VER=14
SUMMARY="GNU C++ compiler runtime dependencies"
DESC="$SUMMARY"

init
prep_build
shopt -s extglob

# To keep all of the logic in one place, links are not created in the .mog

libs="libstdc++"

if is_cross; then
    NO_SONAME_EXPECTED=1
    pushd $DESTDIR.$BUILDARCH >/dev/null
    mkdir -p usr/lib
    install_lib $CROSS_GCC_VER "$libs" "" $CROSSLIB
    install_unversioned $CROSS_GCC_VER "$libs" "" $CROSSLIB
    popd >/dev/null
else
    pushd $DESTDIR >/dev/null
    mkdir -p usr/lib/amd64
    for v in 7 10 12 13 14; do
        install_lib $v "$libs" amd64
    done
    install_unversioned $SHARED_GCC_VER "$libs" amd64
    popd >/dev/null
fi

((EXTRACT_MODE)) && exit
make_package runtime.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
