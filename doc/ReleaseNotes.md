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

### Commands and Command Options

* A new `penv` command is available for viewing the environment of a process
  or core file; this is equivalent to `pargs -e`

* A new `pauxv` command is available for viewing the auxiliary vector of a
  process or core file; this is equivalent to `pargs -x`

### Zones

### LX zones

### ZFS

### Package Management

### Hardware Support

### Installer

### Developer Features

### Deprecated features

* Python 2.7 is deprecated and reaches end-of-support at the end of 2019.
  OmniOS has mostly transitioned to Python 3. A Python 2 package is still
  available but most previously-shipped modules have been obsoleted.

* Several legacy SunSSH compatibility options for OpenSSH were deprecated
  with release r151026 and were removed in r151028. Please ensure that the
  old directives are removed from your configuration files prior to upgrading
  to this release. Refer to
  <https://omniosce.org/info/sunssh> for more details.

### Package changes ([+] Added, [-] Removed, [\*] Changed)

XXX

