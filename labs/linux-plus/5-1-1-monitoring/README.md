# Linux+ 5.1.1: Monitoring

An SNMP agent queried from another machine, and a health check with a
threshold that logs when it fails.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for the Ubuntu VM: query
this VM, `10.99.0.1`, from there. Get a shell there with
`sudo ip netns exec lepeer bash`; it shares this VM's programs, so install
the SNMP client tools on this VM. The lab runs a small web service on
`127.0.0.1:8080`, and makes the journal persistent if it isn't.

## Tasks

1. Install and run an SNMP agent on this VM, enabled at boot, with a
   read-only community `labro` for the network `10.99.0.0/24`, reachable
   from the peer. Open the firewall for it if one is running. From the
   peer, walk `1.3.6.1.2.1.1` and get the uptime `1.3.6.1.2.1.1.3.0`.
2. Write the chapter's health-check script as `health.sh` in your home
   directory: three tries, `OK` with exit 0 if all succeed, `WARNING` with
   exit 1 if some fail, and if all three fail, a `user.crit` log message
   `health: URL failing (CODE)`, `CRITICAL` and exit 2. Run it against
   `http://127.0.0.1:8080/` (OK) and `http://127.0.0.1:9/` (CRITICAL),
   and find the critical message in the journal.

## Hints

- RHEL family: `net-snmp`, `net-snmp-utils`, `/etc/snmp/snmpd.conf`.
  Ubuntu: `snmpd`, `snmp`; its `snmpd.conf` listens on localhost only
  (`agentaddress`). `rocommunity COMMUNITY SOURCE`.
- `firewall-cmd --add-service=snmp` (and `--permanent`), `ufw allow`.
- `snmpwalk -v2c -c labro 10.99.0.1 1.3.6.1.2.1.1`, `snmpget`.
- `curl -s -o /dev/null -w '%{http_code}' --max-time 3`, `logger -p
  user.crit`, `journalctl -p crit --since "5 min ago"`.
