# RHCSA 7.4: Time service clients

Pointing chrony at one time server, and setting the time zone.

## Before you start

The lab adds a time server on your lab network: a second machine, `ntp1`
(`10.99.0.2`), running an NTP server. It's the "server on your network" of
the chapter, so the lab doesn't need the Internet. The lab notes your time
zone and chrony's configuration, and puts them back when you reset it.

## Tasks

1. Make this VM synchronize its time only with `ntp1` (`10.99.0.2`),
   persistently. After a minute, `chronyc sources` lists only that server,
   marked `^*`.
2. Set the time zone to `America/Phoenix`.

## Hints

- `/etc/chrony.conf`: comment out the `pool` line, add a `server` line
  with `iburst`; `systemctl restart chronyd`; `chronyc sources`,
  `chronyc tracking`.
- If your DHCP server hands out NTP servers, they show up in
  `chronyc sources` too: comment out the `sourcedir /run/chrony-dhcp`
  line as well.
- `timedatectl list-timezones`, `timedatectl set-timezone`, `timedatectl`.
