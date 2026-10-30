# LPIC-1 104.5: File permissions and ownership

Octal modes, execute-only directories, the umask, a shared group
directory with setgid and sticky bits, and finding setuid programs.

## Before you start

The lab creates `/root/perm/report.txt` (mode 644) and three users with
password `Lab-Pass-1`: `tess`, and `anna` and `ben` for the shared
directory. Work as root (`sudo -i`) unless a task says otherwise, and
write answers to the files in `/root/lab-answers/`.

## Tasks

1. Work out the octal mode for "owner reads and writes, group reads,
   others nothing", apply it to `/root/perm/report.txt`, and check with
   `ls -l` and `stat -c %a`. Write the mode to `/root/lab-answers/1`.
2. As root, make `/srv/test` with mode `711` and put a readable file in
   it. As `tess`, try `ls` on the directory and `cat` on the file by its
   full path.
3. Set `umask 077`, create a file `/root/perm/f077` and a directory
   `/root/perm/d077`, and check their modes. Do the same with `umask 033`
   for `/root/perm/f033` and `/root/perm/d033`.
4. Build the shared `/srv/web` directory from the chapter for group `web`,
   with `anna` and `ben` as members. With `chmod 2770` and `umask 002`,
   show that each user's new files get the `web` group and that the other
   user can add to them (`echo more >> file`). Then `chmod 3770` and show
   that neither can delete the other's files.
5. List the setuid and setgid programs on your system with `find`, and
   write the list to `/root/lab-answers/5`.

## Hints

- `r` is 4, `w` 2, `x` 1; `chmod`, `stat -c %a`.
- `mkdir -m 711`; `su - tess` (or `sudo -u tess`); `ls /srv/test` and
  `cat /srv/test/FILE`.
- `umask` only affects the current shell; new files start from 666 and
  directories from 777.
- `groupadd web`, `usermod -aG web anna`; `chgrp`, `chmod`. Group
  membership counts from the next login. As each user, `umask 002` before
  creating a file.
- `find / -xdev -type f -perm /6000`.
