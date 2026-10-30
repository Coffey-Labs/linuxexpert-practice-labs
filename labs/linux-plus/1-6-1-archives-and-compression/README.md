# Linux+ 1.6.1: Archives and compression

tar archives, restoring one file, gzip, bzip2 and xz side by side, reading a
compressed log, and cpio.

## Before you start

The lab clears away the files the tasks create in `/tmp`, if they're there.
Ubuntu empties `/tmp` at boot, so do the tasks without a reboot, and run
`le-lab check` before the chapter's clean-up step (`le-lab reset` cleans up
too). Tasks 2 and 3 ask for findings: write them to the files in
`/root/lab-answers/` that they name.

## Tasks

1. Archive `/etc` into `/tmp/etc.tar.gz` with gzip, list it to find
   `sshd_config`, and restore just `etc/ssh/sshd_config` from it into
   `/tmp/restore`.
2. Archive `/etc` without compression into `/tmp/etc.tar`. Copy it to
   `/tmp/t-gzip.tar`, `/tmp/t-bzip2.tar` and `/tmp/t-xz.tar`, and compress
   each with the tool it's named after, keeping the copies. Write the name
   of the tool that made the smallest file to `/root/lab-answers/2`.
3. Save the last 500 lines of the journal, compressed with gzip, as
   `/tmp/j.gz`. Without unpacking it, count the lines that mention `error`
   in any case, and write the count to `/root/lab-answers/3`.
4. From `/etc`, make a cpio archive of the files in `ssh` as
   `/tmp/ssh.cpio`, and unpack it into `/tmp/c`.

## Hints

- `tar -czf`, `tar -tzf`, `tar -xzf ARCHIVE -C DIR MEMBER`.
- `gzip -k`, `bzip2 -k`, `xz -k`; `ls -lh /tmp/t-*`. bzip2 may need
  installing. The tools skip a file whose name already ends in their own
  suffix (`.gz`, `.bz2`, `.xz`).
- `journalctl -n 500 --no-pager | gzip > ...`; `zgrep -c -i`, `zless`.
- `cd /etc && find ssh -type f | cpio -o > ...`; `cpio -idv < ...`.
