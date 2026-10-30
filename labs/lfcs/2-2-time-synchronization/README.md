# LFCS 2.2: Time synchronization

The time zone, chrony and systemd-timesyncd as clients, and chrony as a
server for other hosts.

## Before you start

The lab sets up the peer, a second machine at `10.99.0.2` on the lab
network `10.99.0.0/24`; this VM is `10.99.0.1` there. On Ubuntu the peer
runs an NTP server. Run commands on the peer with
`sudo ip netns exec lepeer COMMAND`.

## Tasks

1. Set the time zone to `Europe/Berlin`.
2. RHEL family: make chrony use only `time.cloudflare.com` (remember the
   `sourcedir /run/chrony-dhcp` line).
3. Ubuntu: make systemd-timesyncd use `time.google.com`.
4. RHEL family: make this VM an NTP server for its lab network,
   `10.99.0.0/24`, so the peer can get the time from it.
5. Ubuntu: make this VM an NTP client of the peer's server, `10.99.0.2`,
   with chrony (install it). Do task 3 first: chrony replaces
   systemd-timesyncd, and task 3 is then graded on its configuration.

## Hints

- `timedatectl list-timezones`, `timedatectl set-timezone`.
- Every source: `server` and `pool` lines, and `sourcedir`, in
  `/etc/chrony.conf`; then restart chronyd and run `chronyc sources`.
- A drop-in in `/etc/systemd/timesyncd.conf.d/`, then
  `timedatectl timesync-status`.
- `allow` in chrony.conf, and the firewall if one runs. Test from the peer
  with `sudo ip netns exec lepeer chronyd -Q 'server 10.99.0.1 iburst'`,
  then `sudo chronyc clients` here.
- `/etc/chrony/chrony.conf` on Ubuntu; the service is `chrony`.
