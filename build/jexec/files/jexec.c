/*
 *
 * This file and its contents are supplied under the terms of the
 * Common Development and Distribution License ("CDDL"), version 1.0.
 * You may only use this file in accordance with the terms of version
 * 1.0 of the CDDL.
 *
 * A full copy of the text of the CDDL should have accompanied this
 * source. A copy of the CDDL is also available via the Internet at
 * http://www.illumos.org/license/CDDL.
 */

/*
 * Copyright 2021 OmniOS Community Edition (OmniOSce) Association.
 */

/*
 * jexec - called by the kernel's javaexec module to run an executable JAR
 * file. This binary must match the ISA of the kernel and will just exec
 * the java interpreter via the mediated link in /usr/bin
 */

#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <unistd.h>

#define JAVA_PATH	"/usr/bin/java"

int
main(int argc, char **argv)
{
	char **nargv;
	int nargc, i;

	if (argc < 2)
		errx(EXIT_FAILURE, "insufficient arguments provided");

	nargc = 0;
	nargv = reallocarray(NULL, argc + 1, sizeof (char *));

	if (nargv == NULL)
		err(EXIT_FAILURE, "malloc failed");

	nargv[nargc++] = JAVA_PATH;

	i = 1;
	while (i < argc)
		nargv[nargc++] = argv[i++];

	nargv[nargc++] = NULL;

	execv(JAVA_PATH, (char * const *)nargv);

	err(EXIT_FAILURE, "exec of " JAVA_PATH " failed.");
}

