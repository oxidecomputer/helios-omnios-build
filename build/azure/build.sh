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

PROG=WAGuestAgent
PKG=system/virtualization/azure-agent
VER=2.2.42
SUMMARY="Microsoft Azure Guest Agent"
DESC="The $SUMMARY (waagent) manages provisioning and VM interaction "
DESC+="with the Azure Fabric Controller."

BUILDDIR=WALinuxAgent-$VER

# The "rmvolmgr" service is relied upon to mount and umount the
# provisioning ISO that is attached to the VM when running on Azure.
RUN_DEPENDS_IPS="
    runtime/python-$PYTHONPKGVER
    system/hyperv/tools
    service/storage/media-volume-manager
"

init
download_source $PROG v$VER ""
patch_source
prep_build
python_build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
