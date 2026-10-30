# LFCS 4.5: Troubleshooting disk space

Finding what fills a filesystem, space held by a deleted file, the journal,
running out of inodes, and log rotation.

## Before you start

The lab makes two small spare filesystems, mounted from `/etc/fstab`:
`/mnt/spare`, a 1 GiB logical volume (ext4) that it has filled with a few
large files, and `/mnt/small`, a 64 MiB ext4 filesystem with few inodes. A
lab service, `applog`, writes a log on `/mnt/spare`. The lab also grows the
journal past 200 MB (making it persistent if it wasn't), creates
`/var/log/myapp/` with two logs, and installs lsof. Write answers to the
files in `/root/lab-answers/`.

## Tasks

1. Find the biggest directory directly under `/mnt/spare`, and the biggest
   file in it. Write the directory's path on line 1 of
   `/root/lab-answers/1`, and the file's path on line 2.
2. `df` and `du` disagree about `/mnt/spare`. Find why, write the name of
   the program or service holding the space to `/root/lab-answers/2`, and
   free the space.
3. Limit the journal to 200 MB permanently, and free the space now.
4. Exhaust the inodes of `/mnt/small` with empty files, then find the
   directory responsible and write its path to `/root/lab-answers/4`.
5. Rotate `/var/log/myapp/*.log` daily, keeping 5 compressed copies, with a
   file `/etc/logrotate.d/myapp`.

## Hints

- `du -xh --max-depth=1 /mnt/spare | sort -h`, `find -xdev -type f -size`.
- `df -h /mnt/spare`, `lsof -a +L1 /mnt/spare`, `ps -o unit= -p PID`;
  restart the holder, or `truncate -s 0 /proc/PID/fd/N`.
- `journalctl --disk-usage`, `SystemMaxUse=` in
  `/etc/systemd/journald.conf.d/`, `journalctl --rotate --vacuum-size=`,
  `systemd-analyze cat-config systemd/journald.conf`.
- `df -i`, `df -h`, `find -xdev | cut -d/ -f1-4 | sort | uniq -c`.
- `daily`, `rotate`, `compress`; `logrotate -d /etc/logrotate.d/myapp`.
