<a href="https://omniosce.org">
<img src="https://omniosce.org/OmniOSce_logo.svg" height="128">
</a>

# Release Notes for OmniOSce v11 r151034
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) ** These are DRAFT release notes ** ![#f03c15](https://placehold.it/15/f03c15/000000?text=+)

Stable Release, TBC of May 2020

`uname -a` shows `omnios-r151034-XXX`

r151034 release repository: https://pkg.omniosce.org/r151034/core

## Upgrade Notes

It is only possible to upgrade to this release from r151030 or r151032. If
starting from an earlier release, upgrade in stages following the guide at
https://omniosce.org/upgrade

## New features since r151032

### System Features

* OmniOS now supports running an NFS server in a native zone (i.e. _ipkg_,
  _lipkg_, _sparse_ or _pkgsrc_ brands). NFS sharing can be enabled by setting
  the `sharenfs` property on a dataset just as in the global zone.

* While it was previously possible to create an SMB share within a zone via
  the `sharemgr` command, it can now be done more easily via the `sharesmb`
  dataset property, as in the global zone (subject to doing the rest of the
  required setup for SMB such as configuring the idmap service).

* Support for overlay networks has been ported from Joyent SmartOS. An overlay
  is effectively an etherstub (virtual switch) that can be distributed across
  hosts. The
  [overlay(5) manual page](https://man.omnios.org/man5/overlay.5.html)
  provides a good overview of this new functionality. The current
  implementation in OmniOS supports sharing an overlay between two hosts
  using the _direct_ plugin and across multiple hosts using statically
  configured rules via the _files_ plugin.

* Improvements to the in-kernel SMB/CIFS support.

* The SMB client has been updated to version 3.02

* Support for SMBIOS 3.3 and decoding of additional information such as
  battery data.

* The OmniOS kernel is now built with mitigations against `swapgs` and `TAA`
  attacks.

* A new AMD temperature sensor driver is available.

* A new `fdinfo` directory is available under `/proc` for each process. This
  directory contains an entry for each of the process' open files and the
  entry contains information about the file. Refer to the
  [proc(4) manual page](https://man.omnios.org/man4/proc.4.html#fdinfo) for
  more details on the file format.

* LDAP group integration has been improved to support more LDAP schemas.

* The `gettimeofday()` function call performance has been significantly
  improved.

### Commands and Command Options

* `ps ww` has been updated to fix a regression introduced in r151032 where
  output would be truncated. The root user can now see all process arguments;
  non-root users are still restricted to seeing the first 4096 characters.

* A new `resize` command is available to set environment and terminal settings
  to the current window size (for supported terminals).

* The `ssh-copy-id` command is provided to easily transfer a publish ssh key
  to a remote system.

* `rdmsr` allows reading of a value from x86 model-specific registers.

* `pfiles` now shows the filesystem endpoints for door servers.

* `ptree` has been extended to support showing line-drawing characters and to
  better wrap output.

* `find -path` now operates correctly for paths starting with a "." character.

### Zones

### LX zones

* Prior to this release, executing a shared library in an LX zone could cause
  it to crash; this has been resolved.

### Bhyve

* Additional bhyve firmware based on a newer version of the reference UEFI
  implementation is now available. This firmware supports UEFI only and does
  not currently support PCI pass-through. To switch to it, set the `bootrom`
  attribute of a bhyve zone to `BHYVE_RELEASE-2.70`.

* It is now possible to set a password for the bhyve VNC server.

* bhyve vioblk devices now support TRIM, although note that illumos guests
  cannot yet use this feature.

* The `bhhwcompat` command has been removed in this release since it no longer
  provides any useful diagnostics.

* In this release, bhyve has acquired multiple additional updates and fixes
  from upstream Joyent and FreeBSD.

### ZFS

* Support for ZFS trim - see the output of `zpool status -t` for details on
  whether it is supported for a particular pool.

* `zpool iostat` and `zpool status` improvements.

* Improved zpool import speed.

* Support for Direct I/O on ZFS filesystems.

### Package Management

rapidjson?

### Hardware Support

* Support for Intel ixgbe X553.

* Support for cxgbe T5/T6 parts.

* Updated cxgbe firmware.

* Support for Mellanox ConnectX-4/5/6 NICs.

* Support for Intel I219 v10-v15.

### Loader

* New menu option to toggle the framebuffer state before boot.

* Improved menu option for selecting the desired KMDB behaviour before boot.

### Developer Features

* The default OmniOS userland compiler is now gcc 9 and produces 64-bit
  objects by default.

* The `developer/gcc9` package now supports compiling objective-C and Go
  programs.

* It is possible to override the version lock for more system packages via
  IPS facets which allows administrators to downgrade these packages more
  easily if it becomes necessary.

* Additional commands have been added to mdb - `::refstr`, `::ps -s`.

* Slave PTYs now operate in a less standards-compliant but more commonly
  expected way. This resolves problems with third party software that does
  anticipate the standards-compliant mode of operation.

* Perl is now shipped 64-bit only.
  Note that in order to continue building illumos-gate on OmniOS you must add
  `export BUILDPERL32='#'` to your .env file.

* The default Python 3 version is now 3.7 and all system packages have been
  updated to use this new version. Python 3.5 and all related modules have
  been deprecated and removed.

* `open(2)` now supports the `O_DIRECTORY` flag.

* The `fmemopen(3C)` and `open_memstream(3C)` functions are now available.

* Extensions to the Device Driver Interface (DDI) to improve the DMA cookie
  APIs.

* KCF and PKCS#11 now support SHA512\_224 and SHA512\_256.

### Deprecated features

* The Python `simplejson` module has been removed in this release. In its place
  there is a new `rapidjson` module which is both faster and less memory
  hungry.

* The `bhhwcompat` command has been removed.

* Python 2 is now end-of-life and will not receive any further updates. The
  `python-27` package is still available for backwards compatibility but will
  be maintained only on a best-efforts basis.

* OpenSSL 1.0.x is deprecated and reached end-of-support at the end of 2019.
  OmniOS has completely transitioned to OpenSSL 1.1.1 but retains the OpenSSL
  1.0.2 libraries for backwards compatibility. The 1.0.2 libraries are
  maintained solely on a best-efforts basis.

### Package changes ([+] Added, [-] Removed, [\*] Changed)

