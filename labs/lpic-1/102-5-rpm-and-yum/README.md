# LPIC-1 102.5: RPM, YUM and Zypper

Querying and verifying installed packages, looking inside a downloaded
package, and undoing an install with the DNF history. (The chapter's
Zypper task needs openSUSE, so it isn't part of this lab.)

## Before you start

The lab adds a comment line to `/etc/ssh/sshd_config` (reset takes it out
again), and notes where the DNF history stands. Write answers to the files
in `/root/lab-answers/`.

## Tasks

1. Find which package owns `/etc/ssh/sshd_config`, list its configuration
   files, then verify the package with `rpm -V`. Write the package name on
   line 1 of `/root/lab-answers/1`, and below it every file `rpm -V`
   reports as changed, one per line.
2. Download the `tree` package with `dnf download` into `/root/rpms`,
   query it with `rpm -qpi` and `rpm -qpl`, and extract one file,
   `usr/bin/tree`, with `rpm2cpio` and `cpio`, so that it ends up as
   `/root/rpms/usr/bin/tree`.
3. Use `dnf provides` to find the package for the `dig` command, which you
   don't have, and write its name to `/root/lab-answers/3`. Install it,
   then undo the install with `dnf history undo last`.

## Hints

- `rpm -qf`, `rpm -qc`, `rpm -V`; the letters say what changed (`5` the
  checksum, `S` the size, `T` the time), `c` marks a configuration file.
- `dnf download --destdir`, `rpm -qpi`, `rpm -qpl`; `rpm2cpio FILE.rpm |
  cpio -idv ./usr/bin/tree`, run inside `/root/rpms`.
- On RHEL 10 and its relatives, the first `dnf provides` downloads the
  repositories' file lists, which can take several minutes on a slow
  mirror. `dnf history`, `dnf history info last`.
