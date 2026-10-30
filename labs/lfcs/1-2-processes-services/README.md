# LFCS 1.2: Processes and services

Signals and nice values, running a service now and at boot, fixing a
broken service, masking, and the default boot target.

## Before you start

The lab creates user `alice` (password `Lab-Pass-1`), installs the `cups`
print service and starts it, stops and disables any web server already
installed, and sets the default boot target to `graphical.target`.

## Tasks

1. As `alice`, start `sleep 3000` in the background, find its PID without
   `ps`, give it nice value 15, then stop it with SIGTERM. Check it
   yourself: `ps -o ni -p PID` shows `15` before you stop it, and
   `pgrep sleep` prints nothing after.
2. Install nginx (or httpd), and make it run now and at every boot.
3. Put a typo in the web server's configuration and restart it. Find the
   exact error line in the logs and write it to `/root/lab-answers/3`. Then
   fix the typo, so the service is running again and `curl -sI localhost`
   returns a status line.
4. Make sure the `cups` service can't be started by anyone.
5. Make the system boot to a text login by default.

## Hints

- `pgrep -u`, `renice -n ... -p`, `kill`.
- `systemctl enable --now`, `systemctl is-active`, `systemctl is-enabled`.
- `systemctl status`, `journalctl -u ... -b`, `nginx -t` or
  `apachectl configtest`.
- `systemctl mask`.
- `systemctl get-default`, `systemctl set-default`.
