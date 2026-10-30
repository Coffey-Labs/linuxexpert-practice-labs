# Linux+ 3.6.2: Integrity, data destruction and banners

Verifying installed packages, AIDE on a small rule set, a pre-login SSH
banner, and wiping a disk.

## Before you start

The lab has changed one file that a package installed, outside `/etc`. It
adds a spare disk, `/dev/loop40` (64 MiB, full of old data), an image file
under `/var/lib/le-lab/disks/`. Write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Verify the installed packages, and find the file outside `/etc` whose
   contents no longer match its package. Write its path to
   `/root/lab-answers/1`, then restore it by reinstalling its package, so
   that the package verifies clean again.
2. RHEL family: install AIDE, and write a small configuration,
   `/root/lab-aide.conf`, that keeps its database in `/root/lab-aide.db`
   (new ones in `/root/lab-aide.db.new`) and watches `/etc/ssh` for
   permissions, owner, group, size and SHA-256. Initialize the database,
   create `/etc/ssh/lab-new-file`, and run a check that reports it. Leave
   the file and the database in place.
3. Show the banner `Authorized use only. Activity is monitored.` before
   SSH logins, from `/etc/issue.net`, through a drop-in in
   `/etc/ssh/sshd_config.d/`. Connect with `ssh localhost` and see it.
4. Wipe `/dev/loop40`: one pass of random data, then zeros. Look at its
   first sector afterward.

## Hints

- `rpm -Va` (`5` means the digest differs), `rpm -qf`, `dnf reinstall`;
  `dpkg --verify`, `dpkg -S`, `apt install --reinstall`.
- `database_in=file:...`, `database_out=file:...`, `/etc/ssh
  p+u+g+s+sha256`; `aide -c FILE --init`, `--check`.
- `Banner /etc/issue.net`; `sshd -t`, `systemctl reload sshd` (`ssh` on
  Ubuntu); `sshd -T | grep banner`.
- `shred -v -n 1 -z`, `hexdump -C -n 512`.
