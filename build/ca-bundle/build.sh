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
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=cabundle
VER=5.11
PKG=web/ca-bundle
SUMMARY="Bundle of Root CA certificates"

nsbuild=$SRCDIR/../mozilla-nss-nspr/build.sh
NSSVER="`grep '^VER=' $nsbuild | sed 's/.*=//;q'`"
NSPRVER="`grep '^NSPRVER=' $nsbuild | sed 's/.*=//;q'`"
# Make-ca from https://github.com/djlucas/make-ca
MAKECAVER=0.6

DESC="Root CA certificates extracted from mozilla-nss $NSSVER source"
DESC+=", plus OmniOS CA cert."

OVERRIDE_SOURCE_URL=none

build_pem() {
    BUILDDIR_ORIG=$BUILDDIR

    # Fetch and extract the NSS source to get certdata.txt
    NSSDIR=nss-$NSSVER
    CERTDATA=nss/lib/ckfw/builtins/certdata.txt
    BUILDDIR=$NSSDIR download_source nss nss "$NSSVER-with-nspr-$NSPRVER" \
        "" "$NSSDIR/$CERTDATA $NSSDIR/nss/COPYING"

    # Fetch and extract make-ca
    MAKECADIR=make-ca-$MAKECAVER
    BUILDDIR=$MAKECADIR download_source make-ca make-ca $MAKECAVER

    BUILDDIR=$BUILDDIR_ORIG

    # The make-ca script has a hard coded sanity check for at least 150
    # certificates. However, the number of trusted roots is now just under 150.
    logcmd sed -i 's/\<150\>/140/g' $TMPDIR/$MAKECADIR/make-ca

    logmsg "-- Generating CA certificate files"
    PATH=/usr/gnu/bin:$PATH logcmd bash $TMPDIR/$MAKECADIR/make-ca \
        --destdir $DESTDIR \
        --certdata $TMPDIR/$NSSDIR/$CERTDATA \
        --keytool /usr/bin/keytool \
        --cafile /etc/ssl/cacert.pem \
        || logerr "Failed to generate certificates"

    logcmd mkdir -p $TMPDIR/$BUILDDIR
    logcmd cp $TMPDIR/nss-$NSSVER/nss/COPYING $TMPDIR/$BUILDDIR/license || \
        logerr "--- Failed to copy license file"

    logcmd cp $DESTDIR/etc/ssl/cacert.pem{,.full}
    sed -n < $DESTDIR/etc/ssl/cacert.pem.full > $DESTDIR/etc/ssl/cacert.pem '
        /^#/p
        /---BEGIN CERT/,/---END CERT/p
    '
    logcmd rm -f $DESTDIR/etc/ssl/cacert.pem.full
}

# Install the OmniOSce CA cert, to be used by pkg(1)
install_omnios_cacert() {
    logmsg "Installing OmniOSce CA certs for pkg(1) use"

    logcmd mkdir -p $DESTDIR/etc/ssl/pkg

    for cert in $SRCDIR/files/*.pem; do
        local file=`basename $cert`
        local subj_hash=`openssl x509 -hash -noout -in $cert`

        logmsg "--- Copying $file"
        logcmd cp $cert $DESTDIR/etc/ssl/pkg/ || \
            logerr "--- Failed to copy CA cert $file"

        logcmd ln -s $file $DESTDIR/etc/ssl/pkg/$subj_hash.0 || \
            logerr "--- Failed to create subject hash link for $file"
    done
}

init
prep_build
build_pem
install_omnios_cacert
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
