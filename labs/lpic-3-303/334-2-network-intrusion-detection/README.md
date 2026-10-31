# LPIC-3 334.2: Network intrusion detection

Snort with local rules, by hand and as a service, and bandwidth monitoring
with ntopng and iftop. Snort and ntopng are packaged for Ubuntu, not for
the RHEL family, so this lab runs on Ubuntu only.

## Before you start

The peer, at `10.99.0.2` (name `peer`), plays the outside host that sends
traffic. It sits on this VM's second network, `10.99.0.0/24`, where this
VM is `10.99.0.1` on interface `le-host`: watch that interface. Get a
shell in the peer with `sudo ip netns exec lepeer bash`; it shares this
VM's files and programs, so install `nmap` here to use it there.

The lab runs a small web server on `10.99.0.1:8080` (`le-lab-app`) with a
large file, `big.bin`. Snort's installer would pick up the lab's
`le-host` interface by a name it can't use and fail, so the lab writes
`/etc/snort/snort.debian.conf` first, with your main interface. OpenVAS
needs a large feed download and several gigabytes of memory, so it isn't
part of this lab.

## Tasks

1. Install Snort and stop the service the package starts. Write two local
   rules in `/etc/snort/rules/local.rules`: an alert for pings (ICMP type
   8) to the home network, `sid:1000001`, and an alert for web requests to
   port 8080 whose URI contains `/lab-admin`, `sid:1000002`. Check that
   the configuration validates with `HOME_NET` set to `10.99.0.0/24` on
   `le-host`.
2. Run Snort by hand on `le-host` with console alerts going to
   `/root/snort-console.txt`. From the peer, ping this VM, ask for
   `http://10.99.0.1:8080/lab-admin`, and send an nmap Xmas scan. Stop
   Snort and read the alerts: your two rules, and the distributed rule
   1228 for the scan.
3. Run Snort as the packaged service instead, on `le-host` with the home
   network `10.99.0.0/24`, set in its Debian configuration file, so that
   pings from the peer land in `/var/log/snort/snort.alert.fast`.
   Summarize that file with `snort-stat`.
4. Install ntopng and iftop. Make ntopng watch `le-host` and answer on
   port 3000. Download `big.bin` over and over from the peer at a limited
   rate, and watch the traffic with an `iftop` text report.

## Hints

- `DEBIAN_FRONTEND=noninteractive apt-get install -y snort`; `systemctl
  stop snort`. `/etc/snort/snort.conf` already includes
  `$RULE_PATH/local.rules`. `alert icmp any any -> $HOME_NET any (msg:"...";
  itype:8; sid:1000001; rev:1;)`; for the web rule, `flow:to_server,established;
  content:"/lab-admin"; http_uri;`. `snort -T -c /etc/snort/snort.conf -i
  le-host -S HOME_NET=[10.99.0.0/24]`.
- `setsid -f timeout 600 snort -A console -q -k none -c ... -i le-host -S
  ... > /root/snort-console.txt 2>&1`; give it half a minute to load.
  `ping -c 2`, `curl`, `nmap -sX -p 22,80 10.99.0.1` from the peer;
  `pkill -x snort` writes out what it buffered.
- `/etc/snort/snort.debian.conf`: `DEBIAN_SNORT_HOME_NET`,
  `DEBIAN_SNORT_INTERFACE`; `systemctl restart snort`, `ps -o args= -C
  snort`; `snort-stat < /var/log/snort/snort.alert.fast`.
- `-i=le-host` in `/etc/ntopng.conf`, `systemctl restart ntopng`;
  `curl --limit-rate 5M`; `iftop -t -n -P -s 10 -i le-host`.
