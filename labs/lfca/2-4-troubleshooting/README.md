# LFCA 2.4: Troubleshooting

A full filesystem, a web server that won't start, DNS, load, and a boot
that stops in emergency mode.

## Before you start

Work as root (`sudo -i`). Answers go in `/root/lab-answers/<task>`.

The lab adds a 1 GiB spare disk with a filesystem mounted at `/data` and
fills most of it with one large file, as if you had run `fallocate` there.
The mount lasts until the next reboot. It installs nginx if it's missing
and puts a typo in `/etc/nginx/nginx.conf`, so nginx fails to start. Reset
puts nginx back as it was.

## Tasks

1. `/data` is nearly full. Find what fills it with `df` and `du`, as if you
   didn't know, and write the full path of the large file to
   `/root/lab-answers/1`.
2. nginx won't start. Find the error with `systemctl status`,
   `journalctl -u nginx` and `nginx -t`, fix it, and get nginx running
   (and starting at boot) again.
3. Put a wrong DNS server in the VM's network settings and diagnose the
   symptoms with `ping` and `dig`. Put it back. Not graded.
4. Install `stress-ng`, run `stress-ng --cpu 2 --timeout 60` (or
   `yes > /dev/null`) and watch the load average in `top`. Not graded.
5. Give root a password, add a bad line to `/etc/fstab`, reboot, and
   recover from emergency mode. Do this only at the VM's console, and take
   a snapshot first. Not graded: the VM booting normally again is your
   check.

## Hints

- `df -h`, then `du -xh --max-depth=1 /data | sort -h`, one level deeper
  each time; `du -a` also shows files, and `ls -la` shows hidden ones.
- `nginx -t` names the file and line. `systemctl restart nginx`,
  `systemctl enable nginx`, `curl -s localhost | head`.
- `resolvectl dns` on Ubuntu; `nmcli connection modify ... ipv4.dns` on
  the RHEL family.
- `stress-ng` is in the RHEL family's AppStream and Ubuntu's universe.
- In emergency mode, `mount -o remount,rw /`, fix `/etc/fstab`,
  `systemctl daemon-reload`, `mount -a`, then `reboot`.
