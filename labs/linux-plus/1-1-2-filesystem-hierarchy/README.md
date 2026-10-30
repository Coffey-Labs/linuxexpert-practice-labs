# Linux+ 1.1.2: The filesystem hierarchy

A tour of the directory tree: links into `/usr`, what uses space under
`/var`, real and virtual filesystems, and which package owns a file.

## Before you start

The lab sets nothing up. Each task asks for a finding: write it to the file
in `/root/lab-answers/` that the task names.

## Tasks

1. Look at `/bin`, `/sbin`, `/lib` and `/tmp` with `ls -ld`. Write the ones
   that are symbolic links, one per line, to `/root/lab-answers/1`.
2. Find the directory under `/var` that uses the most space, and write its
   full path (such as `/var/spool`) to `/root/lab-answers/2`.
3. List the mount points of the real filesystems (not virtual ones such as
   `/proc`), one per line, in `/root/lab-answers/3`.
4. Ask the package manager which package owns `/usr/bin/ls`, and write the
   package name to `/root/lab-answers/4`. Then create `/etc/mynote` and see
   what it says about that file; remove `/etc/mynote` again.

## Hints

- `ls -ld /bin /sbin /lib /tmp`: links start with `l`. Note the `t` at the
  end of `/tmp`'s permissions: the sticky bit.
- `du -sh /var/* 2>/dev/null | sort -h | tail`.
- `findmnt --real`, `df -hT`; `findmnt --real -rn -o TARGET` prints just
  the mount points.
- `rpm -qf` on the RHEL family, `dpkg -S` on Debian and Ubuntu.
