
# Any binaries compiled before we separated out the lib directories for each
# major gcc version will load libraries from /usr/lib.
# Even though there was not supposed to be an ABI change, experience has
# shown that binaries built with older GCC versions experience problems
# when loading the runtimes from gcc8. For that reason, retain version 7
# libraries in /usr/lib. Anything built more recently will use
# version-specific paths.

SHARED_GCC_VER=7

