#!/usr/bin/bash
#
# {{{ CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END }}}
#
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright (c) 2013 by Delphix. All rights reserved.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=bash
VER=5.0
PATCHLEVEL=18
PKG=shell/bash
SUMMARY="GNU Bash"
DESC="GNU Bourne-Again shell (bash)"

# bash-completion version
BCVER=2.11

BUILD_DEPENDS_IPS="library/readline"
RUN_DEPENDS_IPS="system/prerequisite/gnu system/library"

set_arch 64

XFORM_ARGS+="
    -DBCVER=$BCVER
"

init
prep_build

###########################################################################
# Build the bash-completions package, including illumos extensions
# courtesy of OpenIndiana

save_function make_clean _make_clean
make_clean() {
    # Patch the bash completions to use GNU grep and GNU sed since that is
    # what they expect. Now that awk -> nawk, that does not need patching.
    logcmd find completions bash_completion -type f -exec sed -i '
        s/\<grep\>/g&/g
        s/\<sed\>/g&/g
        # The GNU tar completion parses the output of --help and --warnings
        s/\<tar --/g&/g
    ' {} +
}

build_dependency -merge bash-completion bash-completion-$BCVER \
    $PROG bash-completion $BCVER

clone_github_source illumos-completion \
    https://github.com/OpenIndiana/openindiana-completions master

logcmd rm -f $TMPDIR/$BUILDDIR/illumos-completion/*.md
logcmd rsync -av --exclude=.git \
    $TMPDIR/$BUILDDIR/illumos-completion/ \
    $DESTDIR/$PREFIX/share/bash-completion/completions/ || logerr rsync

save_function _make_clean make_clean

###########################################################################

note -n "Building $PROG"

CFLAGS+=" -I/usr/include/ncurses"

# "let's shrink the SHT_SYMTAB as much as we can"
LDFLAGS="-Wl,-z -Wl,redlocsym -lncurses"

CONFIGURE_OPTS="
    --localstatedir=/var
    --enable-alias
    --enable-arith-for-command
    --enable-array-variables
    --enable-bang-history
    --enable-brace-expansion
    --enable-casemod-attributes
    --enable-casemod-expansions
    --enable-command-timing
    --enable-cond-command
    --enable-cond-regexp
    --enable-coprocesses
    --enable-debugger
    --enable-directory-stack
    --enable-disabled-builtins
    --enable-dparen-arithmetic
    --enable-extended-glob
    --enable-help-builtin
    --enable-history
    --enable-job-control
    --enable-multibyte
    --enable-net-redirections
    --enable-process-substitution
    --enable-progcomp
    --enable-prompt-string-decoding
    --enable-readline
    --enable-restricted
    --enable-select
    --enable-separate-helpfiles
    --enable-single-help-strings
    --disable-strict-posix-default
    --enable-usg-echo-default
    --enable-xpg-echo-default
    --enable-mem-scramble
    --disable-profiling
    --enable-largefile
    --enable-nls
    --with-bash-malloc
    --with-curses
    --with-installed-readline=yes
"

download_source $PROG $PROG $VER
patch_source
build
[ -n "$PATCHLEVEL" ] && VER+=".$PATCHLEVEL"
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
