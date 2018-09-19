<a href="https://omniosce.org">
<img src="https://omniosce.org/OmniOSce_logo.svg" height="128">
</a>

# Release Notes for OmniOSce v11 r151028
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) ** These are DRAFT release notes ** ![#f03c15](https://placehold.it/15/f03c15/000000?text=+)

Stable Release, TBC of November 2018

`uname -a` shows `omnios-r151028-XXX`

r151028 release repository: https://pkg.omniosce.org/r151028/core

## Upgrade Notes

* Several legacy SunSSH compatibility options for OpenSSH were deprecated
  with release r151026 and have now been removed. **Please ensure that the
  old directives are removed from your configuration files prior to upgrading
  to this release.**
  Refer to <https://omniosce.org/info/sunssh> for more details.

* The format of package version numbers has changed slightly with this
  release. For example, the terminal/screen package in r151026 looked like
  this:

    _pkg://omnios/terminal/screen@4.6.2,5.11-**0.151026**:20180420T095117Z_

  and as of r151028, the ordering of the branch version has been changed

    _pkg://omnios/terminal/screen@4.6.2,5.11-**151028.0**:20181101T113741Z_

  This allows for better use of the branch version for future package updates.

## New features since r151026

### System Features

* The bhyve hypervisor is much improved and generally suitable for production
  use.

* It is possible to run both KVM and bhyve virtual machines on the same
  physical host.

* bhyve and kvm branded zones are now available. Our website contains
  [documentation](https://omniosce.org/info/bhyve_kvm_brand) on how to make
  use of these.

* The default openssl version is 1.1 and OmniOS itself is now built against
  that version. The system openssl version can be changed back to 1.0.2 via
  the version property of the _openssl_ mediator, i.e.
```
      pkg set-mediator -V 1.0 openssl
```
  To compile software against version 1.0 reglardless of the mediator setting,
  use

  `CFLAGS=-I/usr/ssl-1.0/include LDFLAGS=-L/usr/ssl-1.0/lib/amd64`

  (drop the trailing `/amd64` if building 32-bit software)

* openssh has been upgraded to 7.8p1. This version drops support for some
  very old SSH implementations (pre-2001);
  refer to the [release notes](https://www.openssh.com/txt/release-7.7)
  for more details. Several legacy SunSSH compatibility options for OpenSSH
  that were deprecated in release r151026 have been removed;
  see *Deprecated features* below.

* ZFS support for mounting filesystems in parallel. This significantly
  improves boot time for systems with many filesystems.

* ZFS support for initialising unused blocks with a pattern -
  [see blog post](https://omniosce.org/article/hole-punching)

* Boot archives are now created in _cpio_ format by default. This makes
  for significantly quicker boot archive creation when upgrading.

* Several 32-bit only packages have been moved to 64-bit only.

* OmniOS userland is now built with gcc version 7.

### Commands and Command Options

* New `pptadm` command for managing PCI device pass-through to bhyve virtual
  machines.

* `smbios` can now display more information including that relating to
   power-supply-units (PSUs), cooling devices and voltage and temperature
   probes.

* New `cxgbetool` command for managing Chelsio T4/5/6 NICs.

* The `sasinfo` command now support 12Gb/s SAS.

* `getent` can now list attribute databases such as *auth_attr*. See the
  getent(1m) manpage for more details.

### LX zones

* Support for the Linux auditing subsystem.

* Support for newer IP utilities.

* Many other fixes and compatibility updates from Joyent.

### Package Management

* Automatic naming is now supported for boot environments created during
  package operations. This is configured via the new `auto-be-name` image
  property which specifies a template for the new name; see the man page for
  the `pkg` command for more information and examples. The default property
  value is `omnios-r%r` which results in BE names such as `omnios-r151028x`:

  ```
  # pkg set-property auto-be-name omnios-r%r
  # pkg update
  ...
  A clone of r151028 exists and has been updated and activated.
  On the next boot the Boot Environment omnios-r151028x will be
  mounted on '/'.  Reboot when ready to switch to this updated BE.
  ```

* The `pkg set-publisher` command now accepts the `-r` option to indicate
  that the changes should be applied recursively to linked child zones.
  This makes upgrades easier and our
  [upgrade guide](https://omniosce.org/upgrade) has been updated to make use
  of this new feature.

* The `pkgrecv` command now accepts the `--mog-file` option to allow
  transforms to be applied during package transfer.

* New `--no-network-cache` global option to force cache bypass headers to
  be added to network requests.

* New `nochild` publisher property to allow omission of GZ publisher in
  linked zones, see the _pkg(1)_ man page for more information.

* New `pkgrepo diff` command to compare repositories.

* New `preserve=install-only` option for package manifests, see _pkg(5)_ for
  more details.

* `pkg verify` can now produce parsable JSON output via the `--parsable 0`
  parameter.

* `pkg verify` can now report on unpackaged files via `--unpackaged` and
  `--unpackaged-only`.

* The `release/name` package version now reflects the OmniOS release name
  in its branch revision, for example
  _pkg://omnios/release/name@0.5.11-**151028.28**:20180905T084129Z_
  would correspond to `r151028ab`.

### Hardware Support

* Support for QLogic QL41000/45000 series devices.

* Support for NVMe 1.3 devices.

* Fix for SMB access to some HP scanner models.

### Installer

* The installer has been updated to allow selection of the shell to be used
  for a user created via the post-installation configuration menu.

* The `/etc/inet/hosts` file is now populated based on options selected
  in the post-installation configuration menu.

* When creating an initial user via the post-installation configuration menu
  the user's home directory is now placed on a boot-environment independent
  dataset and the _autofs_ automounter is disabled.

* The installer is now able to force 4k or 8k alignment on the root pool
  regardless of the underlying storage. Previously only 4k was available
  and this did not work for NVMe or virtual disks.

### Developer Features

* GCC version 8 is now available - pkg install developer/gcc8 - and can be
  found in /opt/gcc-8. Details of the changes in GCC 8 can be found on the
  [gcc web site](https://gcc.gnu.org/gcc-8/changes.html).

* The shipped gcc7 and gcc8 compilers will now never honour the
  `-fomit-frame-pointer` directive resulting in binaries which are easier to
  debug.

* The default version of OpenSSL is now 1.1. See *System Features* above
  for more information.

* Python version 3 has been added to the core system; it is not installed
  by default in this release. All python components will be moved over to
  python 3 in the next release in preparation for the python 2 end-of-lif.

* Perl has been upgraded to 5.28.

* sqlite3 is now built with support for additional column metadata API
  functions.

* Some internet address manipulation functions functions have been moved from
  libsocket/nsl to libc.

* The `memset_s(3C)` function is now available.

* New `system/library/gfortran-runtime` package to deliver the runtime
  libraries required to run fortran programs.

* Packaged binaries which previously had been fully stripped now include
  at least the symbol table.

### Deprecated features

* GCC version 6 has been removed; however, if it is already installed on a
  system which is upgraded, then it is left in-place.

* The Sun Availability Suite has been removed.

* Several legacy SunSSH compatibility options for OpenSSH were deprecated
  with release r151026 and have now been removed. Please ensure that the
  old directives are removed from your configuration files prior to upgrading
  to this release. Refer to
  <https://omniosce.org/info/sunssh> for more details.

* Python 2 is deprecated and will become unmaintained starting with the next
  OmniOS release. `/usr/bin/python` is now a mediated link that points to
  python2 by default.

### Package changes ([+] Added, [-] Removed, [\*] Changed)

XXX

