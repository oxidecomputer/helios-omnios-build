<a href="https://omniosce.org">
<img src="https://omniosce.org/OmniOSce_logo.svg" height="128">
</a>

# Release Notes for OmniOSce v11 r151028
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) ** These are DRAFT release notes ** ![#f03c15](https://placehold.it/15/f03c15/000000?text=+)

Stable Release, TBC of November 2018

`uname -a` shows `omnios-r151028-XXX`

r151028 release repository: https://pkg.omniosce.org/r151028/core

## New features since r151026

### System Features

* bhyve virtual machines are now fully supported and recommended in place of
  KVM - see <https://omniosce.org/info/bhyve> for more details.

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
  use `CFLAGS=-I/usr/ssl-1.0/include LDFLAGS=-L/usr/ssl-1.0/lib/amd64`
  (drop the trailing `/amd64` if building 32-bit software)

* openssh has been upgraded to 7.7p1. This version drops support for some
  very old SSH implementations (pre-2001);
  refer to the [release notes](https://www.openssh.com/txt/release-7.7)
  for more details. Several legacy SunSSH compatibility options for OpenSSH
  that were deprecated in release r151026 have been removed;
  see *Deprecated features* below.

* ZFS support for mounting filesystems in parallel. This significantly
  improves boot time for systems with many filesystems.

* ZFS support for initialising unused blocks with a pattern -
  [see blog post](https://omniosce.org/article/hole-punching)

* Boot archives are now created in _cpio_ format by default.

* Several 32-bit only packages have been moved to 64-bit only.

### Commands and Command Options

* New `pptadm` command for managing PCI device pass-through to bhyve virtual
  machines.

* `smbios` can now display power-supply-unit (PSU) information.

* New `cxgbetool` command for managing Chelsio T4/5/6 NICs.

* The `sasinfo` command now support 12Gb/s SAS.

### LX zones

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

### Hardware Support

* Support for QLogic QL41000/45000 series devices.

### Installer

* The installer has been updated to allow selection of the shell to be used
  for a user created via the post-installation configuration menu.

* The `/etc/inet/hosts` file is now populated based on options selected
  in the post-installation configuration menu.

* When creating an initial user via the post-installation configuration menu
  the user's home directory is now placed on a boot-environment independent
  dataset and the _autofs_ automounter is disabled.

### Developer Features

* GCC version 8 is now available - pkg install developer/gcc8 - and can be
  found in /opt/gcc-8. Details of the changes in GCC 8 can be found on the
  [gcc web site](https://gcc.gnu.org/gcc-8/changes.html).

* The default version of OpenSSL is now 1.1. See *System Features* above
  for more information.

* Python version 3 has been added to the core system; it is not installed
  by default in this release. All python components will be moved over to
  python 3 in the next release.

* Perl has been upgraded to 5.28.

* sqlite3 is now built with support for additional column metadata API
  functions.

### Deprecated features

* GCC version 6 has been removed; however, if it is already installed on a
  system which is upgraded, then it is left in-place.

* Several legacy SunSSH compatibility options for OpenSSH were deprecated
  with release r151026 and have now been removed. Please ensure that the
  old directives are removed from your configuration files prior to upgrading
  to this release. Refer to
  <https://omniosce.org/info/sunssh> for more details.

* Python 2 is deprecated and will become unmaintained starting with the next
  OmniOS release. `/usr/bin/python` is now a mediated link that points to
  python2 by default.

* The java-based Amazon EC2 API tools are deprecated and have been removed;
  however, if already installed on a system which is upgraded, then they are
  left in-place. The recommended replacement is the new AWS command-line
  interface which can be installed as follows:
  ```
  # pkg install python-35
  # python3 -m ensurepip
  # pip3 install --upgrade pip
  # pip3 install awscli --upgrade
  # aws --version
  ```

### Package changes ([+] Added, [-] Removed, [\*] Changed)

XXX

