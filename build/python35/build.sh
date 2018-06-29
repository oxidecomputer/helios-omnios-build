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
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=Python
VER=3.5.5
PKG=runtime/python-35
MVER=${VER%.*}
SUMMARY="$PROG $SMVER"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="developer/build/autoconf developer/pkg-config"
RUN_DEPENDS_IPS="
    compress/bzip2
    database/sqlite-3
    library/expat
    library/libffi
    library/libxml2
    library/ncurses
    library/readline
    library/security/openssl
    library/zlib
    system/library/gcc-runtime
"
XFORM_ARGS="-D PYTHONVER=$MVER"

export CCSHARED="-fPIC"
LDFLAGS32="-L/usr/gnu/lib -R/usr/gnu/lib"
LDFLAGS64="-L/usr/gnu/lib/amd64 -R/usr/gnu/lib/amd64"
CPPFLAGS+=" -I/usr/include/ncurses -D_LARGEFILE64_SOURCE"
CPPFLAGS64="`pkg-config --cflags libffi`"
CPPFLAGS32="${CPPFLAGS64/amd64?/}"

CONFIGURE_OPTS="
    --enable-shared
    --with-dtrace
    --with-system-ffi
    --with-system-expat
    --enable-ipv6
"

# We patch auto* files so need to re-generate
preprep_build() {
    run_autoheader
    run_autoconf
    # New file from dtrace patch
    chmod +x $TMPDIR/$BUILDDIR/Include/pydtrace_offsets.sh \
        || logerr "Could not set pydtrace_offsets.sh executable"
}

# Need to set CC='$CC -m64' for 64-bit build in order that macros such as
# LONG_BIT are correctly set
save_function configure64 _configure64
configure64() {
    CC="$CC -m64" _configure64
}

make_prog32() {
    MAKE_ARGS="DFLAGS=-32"
    export DFLAGS=-32
    make_prog
}

make_prog64() {
    # With Python 3, LIBPL is hard-coded rather than being based on LIBDIR
    # As a result, the 64-bit files clobber the 32-bit ones and break the
    # extension builder. Move the 64-bit files to /usr/lib/amd64/...
    LIBPL="`grep LIBPL $DESTDIR/usr/lib/python$MVER/_sysconfigdata-32.py \
        | cut -d"'" -f4 | sed 's^lib/^&amd64/^'`"
    MAKE_ARGS="
        DFLAGS=-64
        DESTSHARED=/usr/lib/python$MVER/lib-dynload
        LIBPL=$LIBPL
    "
    export DFLAGS=-64
    make_prog
}

# Parts of python are architecture dependant. This function saves the
# installed versions after each arch build for later manipulation.
save_arch() {
    bits=$1
    pushd $DESTDIR > /dev/null || logerr "cd $DESTDIR"

    # Save arch-specific sysconfigdata
    if [ "$bits" = 32 ]; then
        mv usr/lib/python$MVER/_sysconfigdata{.py,-$bits.py} \
            || logerr "Cannot archive $bits-bit sysconfigdata"
    else
        mv  usr/lib/python$MVER/lib-dynload/64/_sysconfigdata.py \
            usr/lib/python$MVER/_sysconfigdata-$bits.py \
            || logerr "Cannot archive $bits-bit sysconfigdata"
    fi
    # Save arch-specific pyconfig.h
    mv usr/include/python${MVER}m/pyconfig{.h,-$bits.h} \
        || logerr "Cannot archive $bits-bit pyconfig.h"
    # Save config tree
    LIBPL="`grep LIBPL usr/lib/python$MVER/_sysconfigdata-$bits.py \
        | cut -d"'" -f4 | cut -c2-`"
    rsync -a $LIBPL/ $LIBPL-$bits/

    popd > /dev/null
}

generate_archdeps() {
    logmsg "Fixing architecture-dependent bits"

    # Copy in arch-detecting pyconfig.h
    sed < $SRCDIR/files/pyconfig.h \
        >$DESTDIR/usr/include/python${MVER}m/pyconfig.h "
            s/_MVER_/$MVER/g
        " || logerr "Cannot install pyconfig.h"

    # Restore config trees
    pushd $DESTDIR >/dev/null || logerr "Cannot chdir"
    LIBPL="`grep LIBPL usr/lib/python$MVER/_sysconfigdata-32.py \
        | cut -d"'" -f4 | cut -c2-`"
    logmsg "-- config tree at $LIBPL"
    logcmd rm -rf $LIBPL
    logcmd mv $LIBPL-32 $LIBPL || logerr "libpl 32"
    LIBPL64=`echo $LIBPL | sed 's^lib/^&amd64/^'`
    logcmd mkdir -p `dirname $LIBPL64`
    logcmd mv $LIBPL-64 $LIBPL64 || logerr "libpl 64"
    sed -i '/LIBPL/s^lib/^&amd64/^' usr/lib/python$MVER/_sysconfigdata-64.py \
        || logerr "libpl 64 sed"
    popd >/dev/null

    # Generate 32/64-bit agile _sysconfigdata.py
    pushd $DESTDIR/usr/lib/python$MVER >/dev/null || logerr "Cannot chdir"
    cat << EOM > _sysconfigdata.py
import sys

if sys.maxsize > 2**32:
`sed 's/^/    /' < _sysconfigdata-64.py`
else:
`sed 's/^/    /' < _sysconfigdata-32.py`
EOM
    rm -f __pycache__/_sysconfigdata*
    popd > /dev/null
}

#TESTSUITE_SED="
#    s/.*load avg: .*\] /  /
#    /DeprecationWarning.*exc_clear/d
#    s/ passed in [0-9].*//
#    /No differences encountered/d
#"

launch_testsuite() {
    # Skip network tests. Many of them rely on an open Internet connection.
    export EXTRATESTOPTS="-uall,-network"
    # Some tests have non-ASCII characters
    _LC_ALL=$LC_ALL
    export LC_ALL=en_US.UTF-8
    LC_ALL=$LC_ALL run_testsuite "$@"
    export LC_ALL=$_LC_ALL
}

make_install32() {
    make_install
    save_arch 32
    launch_testsuite test "" testsuite-32.log
}

make_install64() {
    MAKE_INSTALL_ARGS=DESTSHARED=/usr/lib/python$MVER/lib-dynload make_install
    save_arch 64
    launch_testsuite
}

init
download_source $PROG $PROG $VER
patch_source
preprep_build
prep_build
build
generate_archdeps
make_isa_stub
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
