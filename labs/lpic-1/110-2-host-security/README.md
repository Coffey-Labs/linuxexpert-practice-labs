# LPIC-1 110.2: Setting up host security

Turning off a service nobody needs, `/etc/nologin`, and the `nologin`
shell.

## Before you start

The lab runs a service nobody needs, `legacy-echo`, which listens on TCP
port 7007. It creates users `tess` and `testuser` (password `Lab-Pass-1`);
`tess` can log in over SSH with the key `/root/lab-keys/tess`
(`ssh -i /root/lab-keys/tess tess@localhost`). Keep a root session open
while you do task 2.

## Tasks

1. List every listening service with `ss -tulpn`, and turn off
   `legacy-echo` with `systemctl disable --now`. Check it's gone, then mask
   it and try to start it.
2. Create `/etc/nologin` with a message, and try to log in as `tess` over
   SSH (and on the console, if you have one). Then remove `/etc/nologin`
   from the session you kept open.
3. Give `testuser` the shell `/usr/sbin/nologin` and try `su - testuser`.

## Hints

- `ss -tulpn | grep 7007`; `systemctl status legacy-echo`;
  `systemctl mask`, `systemctl start`.
- `echo "Down for maintenance" > /etc/nologin`; root can still log in.
  `journalctl --since -10min` shows the refused login.
- `usermod -s`, `getent passwd testuser`.
