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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=WAGuestAgent
PKG=system/virtualization/azure-agent
VER=2.2.54
SUMMARY="Microsoft Azure Guest Agent"
DESC="The $SUMMARY (waagent) manages provisioning and VM interaction "
DESC+="with the Azure Fabric Controller."

: ${AGENT_SOURCE_REPO:=$GITHUB/WAGuestAgent}
: ${AGENT_SOURCE_BRANCH:=ooce-$VER}

download_source() {
    clone_github_source $PROG \
        "$AGENT_SOURCE_REPO" "$AGENT_SOURCE_BRANCH" "$AGENT_CLONE"
    set_builddir "$BUILDDIR/$PROG"
}

# The "rmvolmgr" service is relied upon to mount and umount the
# provisioning ISO that is attached to the VM when running on Azure.
RUN_DEPENDS_IPS="
    runtime/python-$PYTHONPKGVER
    system/hyperv/tools
    service/storage/media-volume-manager
"

init
download_source
patch_source
prep_build
python_build
install_smf network waagent.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
