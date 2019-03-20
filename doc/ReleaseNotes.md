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

* The console now has full framebuffer support with variable resolution,
  more colours and unicode fonts. This is also visible in the boot loader.

* Support for UEFI boot.

* Several 32-bit only packages have been moved to 64-bit only.

* OmniOS userland is now built with gcc version 8.

* A default installation now includes `ntpsec` in place of `ntp`; the package
  can still be removed if not required.

* A default set of system default parameters are now installed in
  `/etc/system.d/_omnios:system:defaults`. These can be overidden if necessary
  by creating additional local files under `/etc/system.d/`.

### Commands and Command Options

* The `ipadm` and `dladm` commands now show IP and link information if invoked
  without arguments.

* `dladm show-vnic` now shows the zone which which each VNIC is assigned.

* The default behaviour of recursive `chown` and `chgrp` has changed and these
  commands are now safer with respect to following symbolic links. If only
  the `-R` parameter is provided then these utilities now behave as if `-P`
  was also specified. Refer to the chown(1) and chgrp(1) manual pages for more
  information.

* The `/usr/lib/fm/fmd/fmtopo` command has improved support for enumerating
  USB topology.

### Zones

* The defaults for new zones have changed. Creating a new zone now initially
  sets `brand=lipkg` and `ip-type=exclusive`.

* Zone brand templates are available allowing zones to be created within
  zonecfg via: `create -t <type>`.

* `pkgsrc` branded zones are now available; these are sparse zones with pkgsrc
  pre-installed.

* Zone VNICs and networking information can now be dynamically managed as part
  of the zone configuration. Refer to <https://omniosce.org/setup/zones>
  for more details.

* The memory footprint of zones has been reduced by disabling unecessary
  services.

### LX zones

* Many other fixes and compatibility updates from Joyent.

### ZFS

* Support for importing pools using a temporary name.

* Support for variable-sized dnodes.

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

* Automatic boot-environment names can now be based on the current date and
  time as well as the publication date of the update. Refer to the pkg(5)
  man page for more information. Example:
  ```
  # pkg set-property auto-be-name time:omnios-%Y.%m.%d
  ```

### Hardware Support

* Support for modern AMD and Intel systems.

* New para-virtualisation drivers for running OmniOS under Microsoft
  Hyper-V/Azure. These are delivered by the new `driver/hyperv/pv` package.

* New `bnx` (Broadcom NetXtreme) network driver.

* Improved support for USB 3.1.

### Installer

* ZFS streams used for installation are now compressed using `xz` format.
  This has resulted in a decrease in the size of all media. Kayak now
  supports installing from ZFS streams compressed with any of _gzip_, _bzip2_
  or _xz_.

* The first boot of a newly installed system is now quicker due to
  the service management framework being pre-seeded.

### Developer Features

* Python version 3 is now the default python version and most packages have
  been updated so that they use Python 3; a noteable exception is the
  `mercurial` package which does not yet support Python 3.
  Most python 2.7 modules have been removed.
  Python bindings for libxml2 and libxslt have been removed.

* Perl has been upgraded to 5.30.

* OpenJDK has been upgraded to 1.8.

* A new native name demangling library is available
  [illumos issue 6375](https://illumos.org/issues/6375).

* The `mdb` _::dcmds_ and _::walkers_ commands now take an optional filter
  argument to limit the returned results.

* `mdb` has been extended with the ability to trace processes inside bhyve
  virtual machines.

* Rather than editing `/etc/system`, settings can be applied in fragment
  files under `/etc/system.d/`. This allows for separation of settings
  by function, and allows them to be delivered by packages.
  Refer to the system(4) manual page for more information.

* SMF method scripts that leave no processes running but should not be
  considered to have failed may now exit with `$SMF_EXIT_NODAEMON` to
  indicate this to the system. Refer to the smf\_method(5) manual page for
  more information.

* Sun Studio is no longer required to build OmniOS and is no longer shipped.

* Lint libraries are no longer shipped.

* New public `getrandom(2)` interface.

* The linux-compatible inotify(5) driver is now a first-class citizen and
  `/usr/include/sys/inotify.h` is present. NB: Some broken software spots
  this file and uses it as a hint to use Linux-specific features.

### Deprecated features

* Python 2.7 is deprecated and reaches end-of-support at the end of 2019.
  OmniOS has mostly transitioned to Python 3. A Python 2 package is still
  available but most previously-shipped modules have been obsoleted.

* Python bindings for libxml2 and libxslt have been removed.

* Several legacy SunSSH compatibility options for OpenSSH were deprecated
  with release r151026 and were removed in r151028. Please ensure that the
  old directives are removed from your configuration files prior to upgrading
  to this release. Refer to
  <https://omniosce.org/info/sunssh> for more details.

### Package changes ([+] Added, [-] Removed, [\*] Changed)

XXX

