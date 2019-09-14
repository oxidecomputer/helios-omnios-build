<a href="https://omniosce.org">
<img src="https://omniosce.org/OmniOSce_logo.svg" height="128">
</a>

# Release Notes for OmniOSce v11 r151032
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) ** These are DRAFT release notes ** ![#f03c15](https://placehold.it/15/f03c15/000000?text=+)

Stable Release, TBC of November 2019

`uname -a` shows `omnios-r151032-XXX`

r151032 release repository: https://pkg.omniosce.org/r151032/core

## Upgrade Notes

## New features since r151030

### System Features

* OmniOS now supports UEFI boot. Any existing system which has space for an
  EFI system partition (ESP) on the root pool disks will automatically become
  UEFI-boot enabled following upgrade.

* ZFS now has support for native encryption, TRIM, allocation classes and more.

* Many improvements to the in-kernel SMB/CIFS support, including support for
  SMB3 and some Apple extensions for SMB2.

* It is now possible to disable Simultaneous Multithreading (SMT) /
  hyperthreading if desired. This can be done at runtime via `psradm -aS`
  or at boot time by adding `smt_enabled=0` to a file under `/boot/conf.d/`

* Support for plugabble TCP congestion control algorithms, configured via
  `ipadm`
  ```terminal
  omnios# ipadm show-prop tcp -p congestion_control
  PROTO PROPERTY              CURRENT      POSSIBLE
  tcp   congestion_control    sunreno      sunreno,newreno,cubic
  ```

* The new `C.UTF-8` locale is available. This has all the characteristics of
  the default C locale, other than having UTF-8 as its character map. It is
  useful when one needs to have default messages, default collation rules
  but take advantage of Unicode characters.

* Improvements to the Enlightened Hyper-V drivers for running under Hyper-V
  or Microsoft Azure.

* The default crypt algorithm for passwords is now SHA512 (it was previously
  SHA256).

* The OmniOS kernel is now built with retpolines and other mitigations against
  CPU side-channel attacks.

### Commands and Command Options

* A new `penv` command is available for viewing the environment of a process
  or core file; this is equivalent to `pargs -e`

* A new `pauxv` command is available for viewing the auxiliary vector of a
  process or core file; this is equivalent to `pargs -x`

* A new `connstat` command is available for monitoring per-connection
  TCP statistics.

* `netstat` now supports the `-u` option to show information about the
  process that is associated with open sockets.

* `nm` now supports the `-i` option to output symbols in the same order as
  they are present in the symbol table.

* `zoneadm list` now supports the `-n` option to show non-global zones
  only.

* `praudit` now supports the `-p` and `-g` flags in order that it can use
  a specified version of the *passwd* and *group* files when parsing audit
  logs.

* `ps` now supports the `-F` option which generates a full listing (as `-f`)
   but shows the full current process arguments and not the truncated start
   arguments. The current arguments may have changed since the process was
   started.
   ```
   omnios# ps -ef | grep sendmail
      smmsp   623     1   0 23:18:54 ? 0:00 /usr/lib/smtp/sendmail/sendmail -Ac -q15m
   omnios# ps -eF | grep sendmail
      smmsp   623     1   0 23:18:54 ? 0:00 sendmail: Queue runner@00:15:00 for /var/spool/clientmqueue
    ```

* `pgrep` and `pkill` also now support the `-F` option in addition to the
  existing `-f`. As for ps, this matches against and displays the current
  process arguments instead of the truncated start arguments.
  ```
   omnios# pgrep -Fl sendmail:
     623 sendmail: Queue runner@00:15:00 for /var/spool/clientmqueue
   omnios# pgrep -fl sendmail
     623 /usr/lib/smtp/sendmail/sendmail -Ac -q15m
  ```

* `ps auxww` no longer shows truncated process start arguments when run without
  root privileges; the output is now consistent regardless.

* `ptree` supports the new `-s` option to filter the output to processes
  started by an SMF service.

### Zones

### LX zones

* Improved support for newer Linux distributions.

* The sendmmsg() and recvmmsg() system calls are now supported.

* Improved emulation of SO\_REUSEADDR.

* Support Linux congestion control interfaces.

### Bhyve

* Performance improvements.

* Support for emulated NVME devices.

* A bhyve guest will now receive multicast packets from the network.

* LSO support for virtual network interfaces.

* Beta bhyve UEFI firmware has been added.

### ZFS

* Support for native encryption.

* Support for
  [pool allocation classes](https://zfs.datto.com/2017\_slides/brady.pdf).

* Support for UNMAP/TRIM for SSD devices.

* ZFS now uses sorted scans (scrubs/resilvers/TRIM) which can significantly
  improve performance of these operations.

* Support for specifying a desired `ashift` at pool creation time via
  `zpool create -o ashift=XX pool ...`. This can also be specified during
  device attach or replacement to override pool requirements at the expense
  of performance, which can be useful if it is necessary to add a 4K-sector
  drive to an existing pool with ashift=9.

### Package Management

### Hardware Support

* Several updates to the `nvme` driver to fix problems and increase
  hardware support.

* Updated `cxgbe` firmware.

* Several improvements to the `i40e` driver.

* Support for FTDI FT230XQ USB transceivers.

* Support for new Cascade Lake instructions.

* Support for XHCI polled mode support for USB keyboards.

### Installer

* Support for enabling UEFI boot during installation.

* New post-installation configuration option to enable the serial console.

* Automatically install hypervisor support packages if installing inside a
  virtual machine.

* `nvmeadm` is now available from the installer shell.

* `dmesg` now works from the installer shell.

### Developer Features

* The illumos components of OmniOS are now built with GCC 7.

* NMI behaviour can now be easily set at boot time via the `nmi` boot option.
  For example, placing `nmi=kmdb` in a file under `/boot/conf.d/` will select
  this behaviour on each boot.

* Improvements to, and new commands in, `mdb`.

* Improved CTF tools and new `developer/debug/ctf` package.

* Perl has been upgraded to 5.30.

* `nawk` has been updated - see
  [illumos issue 11552](https://www.illumos.org/issues/11552)
  for more details.

* A `python-37` package is now available. The next release of OmniOS will move
  to this version and deprecate the existing `python-35` package and
  associated modules.

* Extensions the Device Driver Interface (DDI) so that drivers have a standard
  mechanism for reporting firmware information.

### Deprecated features

* The gcc5 package has been removed from this release.

* Python 2.7 is deprecated and reaches end-of-support at the end of 2019.
  OmniOS has mostly transitioned to Python 3. A Python 2 package is still
  available but most previously-shipped modules have been obsoleted.

* OpenSSL 1.0.x is deprecated and reaches end-of-support at the end of 2019.
  OmniOS has completely transitioned to OpenSSL 1.1.1 but retains the
  OpenSSL 1.0.2 libraries for backwards compatibility.

### Package changes ([+] Added, [-] Removed, [\*] Changed)

XXX

