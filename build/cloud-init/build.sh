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

. ../../lib/functions.sh

PROG=cloud-init
VER=21.3
PKG=system/management/cloud-init
SUMMARY="Cloud instance initialisation tools"
DESC="Cloud-init is the industry standard multi-distribution method for "
DESC+="cross-platform cloud instance initialisation"

PYMVER=${PYTHONVER%%.*}    # 3
SPYVER=${PYTHONVER//./}    # 39

set_builddir $PROG-illumos-$VER

RUN_DEPENDS_IPS+="
    library/python-$PYMVER/idna-$SPYVER
    library/python-$PYMVER/jsonschema-$SPYVER
    library/python-$PYMVER/pyrsistent-$SPYVER
    library/python-$PYMVER/six-$SPYVER
    library/python-$PYMVER/pyyaml-$SPYVER
"

_site=$PREFIX/lib/$PROG/python$PYTHONVER

function install_deps {
    local _pip="$PYTHON -mpip install -Ut $DESTDIR/$_site"

    logmsg "--- installing python dependencies"
    logcmd mkdir -p $DESTDIR/$_site || logerr "mkdir $DESTDIR/$_site"
    logcmd $_pip -r $TMPDIR/$BUILDDIR/requirements.txt
    logcmd $_pip pyserial

    export PYTHONPATH=$DESTDIR/$_site
    PYINST64OPTS+=" --install-lib=$_site"
}

function fixup_path {
    for f in cloud-id cloud-init; do
        logcmd sed -i "
            /^import sys/a\\
from site import addsitedir\\
addsitedir('$_site')
        " $DESTDIR/usr/bin/$f || logerr "sed $f failed"
    done
}

PYINST64OPTS="--init-system=smf"

init
download_source $PROG illumos $VER
patch_source
prep_build
install_deps
python_build
fixup_path
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
