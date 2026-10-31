# Using Linux Terminal 2.4: Troubleshooting with logs

Finding why a service failed, spotting a failed SSH login, and filtering
the journal by priority and by source.

## Before you start

Work as root (`sudo -i`), and write answers to the files in
`/root/lab-answers/`. The peer, at `10.99.0.2`, stands in for another
machine: get a shell there with `ip netns exec lepeer bash`, and this VM
is `10.99.0.1` from it. The lab also logs two error messages, one from a
program and one from the kernel. Do task 3 within an hour of starting the
lab (or reset and start again).

## Tasks

1. Create `/etc/systemd/system/broken.service` with
   `ExecStart=/usr/local/bin/missing`, run `daemon-reload` and start it.
   Find the reason it failed using only systemctl and journalctl, and write
   the exit status `systemctl status` shows (such as `status=...`) to
   `/root/lab-answers/1`.
2. From the peer, try to SSH to this VM (`10.99.0.1`) as a user that
   doesn't exist, and write the name you used to `/root/lab-answers/2`.
   Find the attempt in `/var/log/auth.log` and in the journal.
3. List every message of priority err or worse from the last hour, then
   only the kernel's, and save that kernel-only list in
   `/root/lab-answers/3`.

## Hints

- `systemctl status broken`, `journalctl -u broken`.
- `ip netns exec lepeer ssh NAME@10.99.0.1`; `grep 'Invalid user'
  /var/log/auth.log`; `journalctl -u ssh --since "5 min ago"`.
- `journalctl -p err --since "1 hour ago"`; `-k` keeps only the kernel's.
