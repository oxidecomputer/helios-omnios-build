<a href="https://omnios.org">
<img src="https://omnios.org/OmniOSce_logo.svg" height="128">
</a>

# Release Notes for OmniOSce v11 r151040
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) ** These are DRAFT release notes ** ![#f03c15](https://placehold.it/15/f03c15/000000?text=+)

Stable Release, TBC of November 2021

`uname -a` shows `omnios-r151040-XXX`

r151040 release repository: https://pkg.omnios.org/r151040/core

## Upgrade Notes

Upgrades are supported from the r151038 release only. If upgrading from an
earlier version, upgrade in stages, referring to the table at
<https://omnios.org/upgrade>.

## New features since r151038

### System Features

### Commands and Command Options

### Libraries and Library Functions

### Zones

### LX zones

### Bhyve

### ZFS

### Package Management

### Hardware Support

### Installer

### Virtualisation

### Developer Features

### Deprecated features

* OpenSSH in OmniOS no longer provides support for GSSAPI key exchange.
  This was removed in release r151038.

* Python 2 is now end-of-life and will not receive any further updates. The
  `python-27` package is still available for backwards compatibility but will
  be maintained only on a best-efforts basis.

* OpenSSL 1.0.x is deprecated and reached end-of-support at the end of 2019.
  OmniOS has completely transitioned to OpenSSL 1.1.1 but retains the OpenSSL
  1.0.2 libraries for backwards compatibility. The 1.0.2 libraries are
  maintained solely on a best-efforts basis.

### Package changes ([+] Added, [-] Removed, [\*] Changed)

