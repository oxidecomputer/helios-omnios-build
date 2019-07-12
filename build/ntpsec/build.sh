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

# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=ntpsec
VER=1.1.6
PKG=service/network/ntpsec
SUMMARY="Network time services"
DESC="A secure, hardened and improved Network Time Protocol implementation"

set_arch 64

# Required to generate man pages
BUILD_DEPENDS_IPS="ooce/text/asciidoc"
export PATH=$PATH:/opt/ooce/bin

SKIP_LICENCES="*"

export XML_CATALOG_FILES=/opt/ooce/docbook-xsl/catalog.xml

# Required to include struct timespec definition and constants.
CFLAGS+=" -D__EXTENSIONS__"
export CFLAGS

# NTPsec uses the 'waf' build system

fix_shebangs() {
    # Although NTPSec components are tested with python3 and can run with
    # either python2 or python3, the default shebang lines just point at
    # '#!/usr/bin/env python'; we need to fix them up to use python3.
    # (NB: there was discussion on the ntpsec mailing list about providing
    #      an option to do this automatically but it has so far been rejected.
    #      Distributions are rolling their own patches, e.g.
    #      https://sources.debian.org/src/ntpsec/1.1.2+dfsg1-4/debian/patches/hardcode-python3-path.patch/
    # Scripting it is more future-proof

    logmsg "--- fix shebangs"
    sed -i '1s^/usr/bin/env python$^/usr/bin/python3^' \
        `find $TMPDIR/$BUILDDIR -type f`
}

make_clean() {
    logcmd ./waf distclean
    fix_shebangs
}

configure64() {
    logmsg "--- configure"
    BIN_ASCIIDOC=/opt/ooce/bin/asciidoc \
        BIN_A2X=/opt/ooce/bin/a2x \
        CC='gcc -m64' \
        logcmd ./waf configure \
        --prefix=/usr \
        --sysconfdir=/etc/inet \
        --refclock=all \
        --define=CONFIG_FILE=/etc/inet/ntp.conf \
        --python=$PYTHON \
        --pythondir=$PYTHONVENDOR \
        --pythonarchdir=$PYTHONVENDOR \
        --nopyc \
        --nopyo \
        --nopycache \
        || logerr "--- configure failed"
    logcmd mkdir -p build/main/pylib
    logcmd ln -s . build/main/pylib/64
}

make_prog() {
    logmsg "--- build"
    logcmd ./waf build || logerr "--- build failed"
}

make_install() {
    logmsg "--- install"
    logcmd ./waf install \
        --destdir=$DESTDIR \
        || logerr "--- install failed"
}

install_ntpdate() {
    logcmd cp $TMPDIR/$BUILDDIR/attic/ntpdate $DESTDIR/usr/bin/ntpdate
    logcmd chmod 755 $DESTDIR/usr/bin/ntpdate
}

install_files() {
    logmsg "--- install files"

    logcmd mkdir -p $DESTDIR/etc/inet
    logcmd cp $SRCDIR/files/ntp.conf $DESTDIR/etc/inet/ntp.conf

    logcmd mkdir -p $DESTDIR/etc/security/auth_attr.d
    logcmd mkdir -p $DESTDIR/etc/security/prof_attr.d
    logcmd cp $SRCDIR/files/security/auth_attr \
        $DESTDIR/etc/security/auth_attr.d/ntp
    logcmd cp $SRCDIR/files/security/prof_attr \
        $DESTDIR/etc/security/prof_attr.d/ntp
}

# Force the testsuite output to be sorted by the binary being tested
# to aid comparison; also remove binary paths from test log.
fix_testsuite_output() {
    [ -z "$SKIP_TESTSUITE" ] && \
        cat $TMPDIR/$BUILDDIR/build/main/test.log | perl -e '
        m|(BINARY\s+:\s).*/([^/]+)$| && push @{$t{$b = $2}}, "$1$b"
            or push @{$t{$b}}, $_ while(<>);
            map {
                s/\\n/\n/g;
                s/^b'"'"'//;
                s/^'"'"'$//;
                s/ tests in [\d\.]+s/ tests/;
                print $_
            } @{$t{$_}} for sort keys %t
    ' > $SRCDIR/testsuite.log
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
fix_testsuite_output
install_ntpdate
install_files
install_smf network ntpsec.xml ntpsec
python_compile
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
