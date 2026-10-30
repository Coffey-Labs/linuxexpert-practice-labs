# LPIC-1 102.3: Shared libraries

Finding the libraries a program needs and the packages they came from,
the three kinds of library name, and adding a directory to the linker's
search path.

## Before you start

The lab installs the SSH client if it's missing. Write answers to the
files in `/root/lab-answers/`.

## Tasks

1. Run `ldd` on `/usr/bin/ls`, `/usr/bin/ssh` and `/usr/bin/bash`. Pick
   one library from each and find which package installed it. Write one
   line per program to `/root/lab-answers/1`: the program, the library
   and the package, such as `ls libselinux.so.1 libselinux`.
2. Look at `ls -l` of `libc.so*` and `libz.so*` in your library directory
   and name each kind of name. Write zlib's soname on line 1 of
   `/root/lab-answers/2`, and its real name (the file the soname points
   to) on line 2.
3. Make an empty directory `/opt/test/lib`, add it to a file in
   `/etc/ld.so.conf.d/`, run `ldconfig -v | grep /opt` and see it scanned.
   Then remove the file and run `ldconfig` again. Check it yourself:
   `ldconfig -v 2>/dev/null | grep /opt` prints the directory while the
   file is there, and nothing after.

## Hints

- `rpm -qf FILE` on the RHEL family, `dpkg -S FILE` on Debian and Ubuntu.
  If `dpkg -S` finds nothing for a path under `/lib`, try it under
  `/usr/lib` (or the other way round).
- The library directory is `/usr/lib64` on the RHEL family and
  `/usr/lib/x86_64-linux-gnu` on Debian and Ubuntu; `ldconfig -p | grep libz`.
- Real name `libz.so.1.3`, soname `libz.so.1`, linker name `libz.so`;
  `readlink`, `objdump -p FILE | grep SONAME`.
