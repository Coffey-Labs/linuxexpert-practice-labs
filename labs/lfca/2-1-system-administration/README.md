# LFCA 2.1: System administration

A sudo user, a web server as a service, a new disk mounted at boot, and a
cron job.

## Before you start

Work as root (`sudo -i`). The lab adds a 1 GiB spare disk, `/dev/loop40`,
standing in for a second virtual disk; it comes back at every boot. It
notes whether nginx is installed, and reset puts that back.

## Tasks

1. Create a user, add them to the `wheel` group (RHEL family) or `sudo`
   group (Ubuntu), log in as them, and run `sudo -l` to see what they may
   do. Then delete the user. Not graded.
2. Install nginx, enable and start it with `systemctl enable --now`, check
   `systemctl status`, fetch the page with `curl localhost`, and read its
   log with `journalctl -u nginx`.
3. Partition `/dev/loop40` (one partition is enough), make an ext4
   filesystem on the partition, mount it at `/data`, add it to
   `/etc/fstab`, and reboot to prove it comes back.
4. Add a root crontab entry that writes the date to `/root/cron-date.txt`
   every two minutes. Check the file once the job has run, then remove the
   entry, leaving the file.

## Hints

- `useradd -m -G wheel NAME` (or `-G sudo`), `passwd NAME`,
  `su - NAME`, `sudo -l`, `userdel -r NAME`.
- `dnf install nginx` / `apt install nginx`, `systemctl enable --now
  nginx`, `curl -s localhost | head`.
- `fdisk /dev/loop40` (or `parted`), then `lsblk /dev/loop40`;
  `mkfs.ext4 /dev/loop40p1`, `blkid`, a `UUID=` line in `/etc/fstab`,
  `systemctl daemon-reload`, `mount -a`, `findmnt /data`.
- `crontab -e` with `*/2 * * * * date >> /root/cron-date.txt`;
  `crontab -l`.
