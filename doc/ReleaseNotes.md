<a href="https://omniosce.org">
<img src="https://omniosce.org/OmniOSce_logo.svg" height="128">
</a>

# Release Notes for OmniOSce v11 r151030
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) ** These are DRAFT release notes ** ![#f03c15](https://placehold.it/15/f03c15/000000?text=+)

Stable and LTS Release, TBC of May 2019

`uname -a` shows `omnios-r151030-XXX`

r151030 release repository: https://pkg.omniosce.org/r151030/core

## Upgrade Notes

* Several legacy SunSSH compatibility options for OpenSSH were deprecated
  with release r151026 and were removed in r151028. **Please ensure that the
  old directives are removed from your configuration files prior to upgrading
  to this release.**
  Refer to <https://omniosce.org/info/sunssh> for more details.

* The format of package version numbers changed slightly in the previous
  r151028 release. For example, the terminal/screen package in r151026
  looked like this:

    _pkg://omnios/terminal/screen@4.6.2,5.11-**0.151026**:20180420T095117Z_

  and as of r151028, the ordering of the branch version has been changed

    _pkg://omnios/terminal/screen@4.6.2,5.11-**151028.0**:20181101T113741Z_

  This allows for better use of the branch version for future package updates.

## New features since r151028

### System Features

* Support for the SMB 2.1 client protocol has been added
  [illumos issue 9735](https://illumos.org/issues/9735).

* Several 32-bit only packages have been moved to 64-bit only.

* OmniOS userland is now built with gcc version 8.

* A default installation now includes `ntpsec` in place of `ntp`; the package
  can still be removed if not required.

### Commands and Command Options


### LX zones

* Many other fixes and compatibility updates from Joyent.

### Package Management

* `pkg verify` has gained an option to verify individual files:
  ```
  # chown sys /var
  # pkg verify -p /var
  PACKAGE                                                            STATUS
  pkg://omnios/SUNWcs                                                 ERROR
        dir: var
                ERROR: Owner: 'sys (3)' should be 'root (0)'
  ```

* Individual origins for a publisher can be enabled and disabled using -g to
  specify the origin:
  ```
  # pkg set-publisher -g https://pkg.omniosce.org/bloody/fred/ --disable omnios
  # pkg publisher
  PUBLISHER    TYPE     STATUS   P LOCATION
  omnios       origin   online   F https://pkg.omniosce.org/bloody/core/
  omnios       origin   disabled F https://pkg.omniosce.org/bloody/fred/
  ```

* Package manifests now include SHA-2 hashes for objects, and extended hash
  information for binary objects, alongside the existing SHA-1 information
  for backwards compatibility with older `pkg` versions.

### Hardware Support


### Installer

* ZFS streams used for installation are now compressed using `xz` format.
  This has resulted in a decrease in the size of all media. Kayak now
  supports installing from ZFS streams compressed with any of _gzip_, _bzip2_
  or _xz_.

### Developer Features

* Python version 3 is now the default python version and most packages have
  been updated so that they use Python 3; a noteable exception is the
  `mercurial` package which does not yet support Python 3.
  A number of python 2.7 modules have been removed.

* Perl has been upgraded to 5.30.

* A new native name demangling library is available
  [illumos issue 6375](https://illumos.org/issues/6375).

* The `mdb` _::dcmds_ and _::walkers_ commands now take an optional filter
  argument to limit the returned results.

### Deprecated features

* Several legacy SunSSH compatibility options for OpenSSH were deprecated
  with release r151026 and were removed in r151028. Please ensure that the
  old directives are removed from your configuration files prior to upgrading
  to this release. Refer to
  <https://omniosce.org/info/sunssh> for more details.

### Package changes ([+] Added, [-] Removed, [\*] Changed)

XXX

