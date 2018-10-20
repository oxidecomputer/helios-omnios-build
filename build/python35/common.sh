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

PYTHONVER=3.5
PYVER=$PYTHONVER		# 3.5
PYMVER=${PYTHONVER%%.*}		# 3
SPYVER=${PYTHONVER//./}		# 35

PYTHON=/usr/bin/python$PYTHONVER
RUN_DEPENDS_IPS="runtime/python-$SPYVER "
XFORM_ARGS="
	-D PYTHONVER=$PYVER
	-D PYTHONLIB=$PYTHONLIB/python$PYVER
	-D PYVER=$PYVER
	-D PYMVER=$PYMVER
	-D SPYVER=$SPYVER
"

# Use an extra directory level for building each module since there can be
# multiple versions of python being built in parallel and if they are built
# in the same directory then they will clobber each other.

TMPDIR+="/python$PYVER"
DTMPDIR+="/python$PYVER"
BASE_TMPDIR=$TMPDIR

# We only deliver Python 3 as 64-bit
BUILDARCH=64

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
