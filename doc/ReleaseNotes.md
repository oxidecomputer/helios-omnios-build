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
  were deprecated in release r151026; see *Deprecated features* below.

* ZFS support for mounting filesystems in parallel. This significantly
  improves boot time for systems with many filesystems.

### Commands and Command Options

* New `pptadm` command for managing PCI device pass-through to bhyve virtual
  machines.

##### BEGIN TBC
* `netstat` supports the `-u` option to include information on the process(es)
  to which sockets are associated. A socket may be associated by more than
  one process as shown in the example below:
  ```
  % netstat -nuf inet
     Local Address        Remote Address      User    Pid       Command     Swind Send-Q Rwind Recv-Q    State
  -------------------- --------------------  ------ ------- --------------- ----- ------ ----- ------ -----------
  192.168.1.1.22       192.168.1.79.34640   root        531 sshd           134664     51  128872      0 ESTABLISHED
  192.168.1.1.22       192.168.1.79.34640   af          533 sshd           134664     51  128872      0 ESTABLISHED
  ```
##### END TBC

### LX zones

* Many other fixes and compatibility updates from Joyent.

### Package Management

### Hardware Support

### Developer Features

### Deprecated features

* Several legacy SunSSH compatibility options for OpenSSH were deprecated
  with release r151026 and should be removed from SSH daemon configuration
  files. A future release of OmniOS will remove support for these options
  completely. Refer to <https://omniosce.org/info/sunssh> for more details.

### Package changes ([+] Added, [-] Removed, [\*] Changed)

XXX

