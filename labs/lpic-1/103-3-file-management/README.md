# LPIC-1 103.3: Basic file management

Brace expansion and copying trees, finding files by age and size, tar
archives, the three compressors, and `dd`.

## Before you start

The lab adds a 64 MiB spare disk, `/dev/loop40`, with a partition table
and a little text near the start, and installs `bzip2` if it's missing.
Work as root (`sudo -i`), and write answers to the files in
`/root/lab-answers/`. Files in `/tmp` don't survive a reboot on every
system, so check task 3 before you reboot.

## Tasks

1. Make `/root/practice/a`, `/root/practice/b` and `/root/practice/c`
   with one command, create a file in each with `touch`, then copy the
   whole tree with `cp -a` and remove the copy with `rm -r`.
2. Find every file under `/etc` changed in the last day, and write the
   list to `/root/lab-answers/2-etc`. Find every file over 10 MiB under
   `/usr`, and write that list to `/root/lab-answers/2-usr`.
3. Archive `/etc` into `/root/etc.tar.xz`, list it, and extract only
   `etc/hostname` into `/tmp`.
4. Compress copies of one log file with `gzip`, `bzip2` and `xz` in
   `/root/compress/`, and compare the sizes with `ls -l`.
5. Copy the first megabyte of the spare disk `/dev/loop40` to
   `/root/first-mb.img` with `dd`, and look at it with `od -c | head`.

## Hints

- `mkdir -p /root/practice/{a,b,c}`; `touch`; `cp -a`; `rm -r`.
- `find /etc -type f -mtime -1`; `find /usr -type f -size +10M`.
- `tar -cJf`, `tar -tJf`, `tar -xJf ARCHIVE -C /tmp etc/hostname`.
- `gzip -k` (or `-c`), `bzip2 -k`, `xz -k`; `ls -l`.
- `dd if=/dev/loop40 of=/root/first-mb.img bs=1M count=1`; `od -c | head`,
  or `od -c | grep -v '\\0  \\0'` to skip the zeros.
