# LPIC-3 335.2: Penetration testing

Scan this VM from the peer with nmap: fingerprint it, check that a
firewall change does what you expect, and run some NSE scripts. Only ever
scan machines you own.

## Before you start

Setup installed nginx and runs it on ports 80, 8080 and 8081, so there
is something to find. The peer, at `10.99.0.2` (name `peer`), is the
scanner; it sits on this VM's second network, where this VM is
`10.99.0.1`. Run commands there with `sudo ip netns exec lepeer COMMAND`.
It shares this VM's files, so a scan it saves in `/root/scans` is here
too.

The firewall, if it's running, is yours to open for ports 80, 8080 and
8081. Keep your scans in `/root/scans`. The nftables table only lasts
until a reboot.

## Tasks

1. Install nmap (and `ndiff`, on Ubuntu). From the peer, find the hosts
   on `10.99.0.0/24`, then run a SYN scan of ports 22, 80, 443, 8080 and
   8081 on `10.99.0.1`, saved in all formats as `/root/scans/before`.
   Ports 22, 80, 8080 and 8081 must show `open`.
2. From the peer, probe the services and the operating system on ports
   22, 80 and 8080, with the XML output in `/root/scans/services.xml`.
   Write the nginx version it found (just the number, like `1.2.3`) to
   `/root/lab-answers/2`.
3. On this VM, install nftables if it's missing and add a table `inet
   scanlab` that drops port 8080 and rejects port 8081 with a TCP reset,
   for the peer only. Port 80 must still answer the peer.
4. From the peer, scan again as in task 1, saved as `/root/scans/after`.
   Then run an ACK scan of ports 22, 8080 and 8081, and write the port it
   reports as `filtered` to `/root/lab-answers/4`.
5. Compare the two scans with `ndiff` and save its output in
   `/root/scans/diff.txt`. (Ubuntu only: AlmaLinux has no `ndiff`.)
6. Run the `ssh2-enum-algos` script against port 22 and save the output
   in `/root/scans/ssh-algos.txt`. Count the NSE scripts in the `vuln`
   category and write the number to `/root/lab-answers/6`.

## Hints

- `nmap -sn 10.99.0.0/24`; `nmap -sS -p ... -oA before 10.99.0.1`.
- `-sV -O -oX FILE`; `nginx -v` tells you the answer to check against.
- `nft add table`, `add chain ... '{ type filter hook input priority 0;
  policy accept; }'`, `add rule ... ip saddr 10.99.0.2 tcp dport 8080
  drop`, `... reject with tcp reset`. From the peer:
  `curl --max-time 3 http://10.99.0.1:8080/`.
- `-sA` sorts ports into `filtered` and `unfiltered`.
- `ndiff before.xml after.xml`.
- `--script NAME`; `/usr/share/nmap/scripts/script.db` lists each
  script's categories.
