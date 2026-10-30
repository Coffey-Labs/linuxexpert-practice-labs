# RHCSA 4.6: Starting and stopping network services

Installing and starting a web server, stopping it, adding a port with a
reload, and finding out why a service won't start.

## Before you start

httpd must not be installed yet: the lab refuses to start if it is. The
checks look at the system log (`/var/log/messages`) for the stop in task
2 and the failure in task 4, so do those for real.

## Tasks

1. Install `httpd`, start it now and at every boot, and confirm it's
   listening on port 80.
2. Stop `httpd` and confirm nothing listens on port 80 any more. Then
   start it again.
3. Add `Listen 8080` to a file in `/etc/httpd/conf.d/` and apply it with
   `systemctl reload httpd`, so httpd listens on both 80 and 8080.
4. Break the httpd configuration on purpose (for example a line `Listen`
   with no port), restart it, and find out why it failed; then fix it so
   httpd is active again.

## Hints

- `dnf install httpd`, `systemctl enable --now httpd`, `sudo ss -tlnp`.
- `systemctl stop httpd`, `ss -tln | grep ':80 '`.
- `echo 'Listen 8080' >/etc/httpd/conf.d/...conf`. SELinux allows 8080 for
  httpd by default.
- `systemctl status httpd`, `journalctl -u httpd`, `httpd -t`.
