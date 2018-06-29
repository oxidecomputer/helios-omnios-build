
PYTHONVER=3.5
PYVER=$PYTHONVER		# 3.5
PYMVER=${PYTHONVER%%.*}		# 3
SPYVER=${PYTHONVER//./}		# 35

PYTHON=/usr/bin/python$PYTHONVER
RUN_DEPENDS_IPS="runtime/python-$SPYVER "
XFORM_ARGS="
	-D PYTHONVER=$PYVER
	-D PYTHONLIB=$PYTHONLIB/python$PYVER
	-D PYVER=$PYYVER
	-D PYMVER=$PYMVER
	-D SPYVER=$SPYVER
"

# Use an extra directory level for building each module since there can be
# multiple versions of python being built in parallel and if they are built
# in the same directory then they will clobber each other.

TMPDIR+="/python$PYVER"
DTMPDIR+="/python$PYVER"
BASE_TMPDIR=$TMPDIR

