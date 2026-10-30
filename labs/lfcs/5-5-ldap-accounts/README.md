# LFCS 5.5: LDAP user and group accounts

Running a small LDAP directory, and joining a host to it with SSSD so its
users and groups can log in.

## Before you start

The guide uses two VMs, a directory server and a client; this lab uses one
VM as both. Setup adds the name `ldap.example.org` for this VM to
`/etc/hosts` and installs the LDAP client tools (`ldapsearch`, `ldapadd`).
Don't create local users `alice` or `bob`.

Which server: on Debian and Ubuntu, OpenLDAP is the `slapd` package. On
AlmaLinux and other RHEL relatives, OpenLDAP's server is in EPEL (install
`epel-release`, then `openldap-servers`); 389 Directory Server
(`389-ds-base`), the distribution's own, works for the tasks too.

## Tasks

1. Run an OpenLDAP directory with base `dc=example,dc=org` on this VM,
   reachable at `ldap://ldap.example.org`, with two users and a group that
   contains them both: users `alice` (UID 10001) and `bob` (UID 10002), with
   primary group 10100, home directory `/home/NAME`, shell `/bin/bash` and
   password `Lab-Pass-1`; group `developers` (GID 10100). Test it with
   `ldapsearch -x -H ldap://ldap.example.org -b dc=example,dc=org '(objectClass=posixAccount)'`.
2. Configure this VM with SSSD so those users resolve and can log in,
   getting a home directory at first login. Test it with `getent passwd
   alice`, `id alice` and `su - alice`.
3. Change `bob`'s login shell in the directory to `/bin/sh`, and make this
   VM see it at once. Test it with `getent passwd bob`.
4. Stop SSSD from starting by making `/etc/sssd/sssd.conf` world-readable
   and restarting it. Find the cause in the logs, write the log message
   that names it to `/root/lab-answers/4`, and fix it.

## Hints

- Debian and Ubuntu: `dpkg-reconfigure slapd`. EPEL's OpenLDAP:
  `ldapadd -Y EXTERNAL -H ldapi:///` with the schemas in
  `/etc/openldap/schema/`, and `ldapmodify` for `olcSuffix`, `olcRootDN`
  and `olcRootPW` (`slappasswd`). Then `ldapadd -x -D ... -W` and
  `ldappasswd`.
- `/etc/sssd/sssd.conf`; without TLS, the guide's two lab-only options.
  `authselect` and `oddjobd`, or `libnss-sss`, `libpam-sss` and
  `pam-auth-update`.
- `ldapmodify`, `sss_cache`.
- `systemctl status sssd`, `journalctl -u sssd`.
