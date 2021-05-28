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
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh
. common.sh

PKG=system/library/g++-runtime
PROG=libstdc++
VER=10
SUMMARY="GNU C++ compiler runtime dependencies"
DESC="$SUMMARY"

init
prep_build
shopt -s extglob

# Abort if any of the following commands fail
set -o errexit
pushd $DESTDIR >/dev/null

# To keep all of the logic in one place, links are not created in the .mog

mkdir -p usr/lib/$ISAPART64

libs="libstdc++"

for v in 7 9 10; do
    install_lib $v "$libs"
done

install_unversioned $SHARED_GCC_VER "$libs"

popd >/dev/null
set +o errexit

make_package runtime.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
