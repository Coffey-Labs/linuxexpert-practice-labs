# RHCSA 9.4: Privileged access

sudo without a password for a group, one command for one user, and full
sudo the RHEL way.

## Before you start

The lab creates group `devs` with member `dan`, and users `gina` and
`alice` (password `Lab-Pass-1` for all three). It notes `/etc/sudoers` and
`/etc/sudoers.d/` so reset can put them back.

## Tasks

1. Let the members of group `devs` run any command as root without a
   password.
2. Let user `gina` run only `systemctl restart httpd` as root.
3. Give `alice` full sudo the RHEL way, with her password.

## Hints

- A file in `/etc/sudoers.d/`, edited with `visudo -f` (or checked with
  `visudo -c`); `%devs ALL=(ALL) NOPASSWD: ALL`. As `dan`: `sudo -n id -u`.
- `gina ALL=(root) /usr/bin/systemctl restart httpd`; as `gina`:
  `sudo -l`. Install `httpd` if you want to run it for real.
- The `wheel` group; `usermod -aG`; `id alice`, `sudo -l -U alice`.
