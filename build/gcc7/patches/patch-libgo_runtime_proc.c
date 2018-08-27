$NetBSD: patch-libgo_runtime_proc.c,v 1.1 2013/04/02 09:57:52 jperkin Exp $

SunOS libelf does not support largefile.

diff -wpruN '--exclude=*.orig' a~/libgo/runtime/proc.c a/libgo/runtime/proc.c
--- a~/libgo/runtime/proc.c	1970-01-01 00:00:00
+++ a/libgo/runtime/proc.c	1970-01-01 00:00:00
@@ -12,6 +12,10 @@
 #include "config.h"
 
 #ifdef HAVE_DL_ITERATE_PHDR
+#ifdef __sun
+#undef _FILE_OFFSET_BITS
+#define _FILE_OFFSET_BITS 32
+#endif
 #include <link.h>
 #endif
 
