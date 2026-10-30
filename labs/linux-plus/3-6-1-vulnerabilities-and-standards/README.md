# Linux+ 3.6.1: Vulnerabilities, detection and standards

Scanning your own machine, finding CVEs in a package's changelog, and a
CIS benchmark scan.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for the Ubuntu VM: scan
this VM, `10.99.0.1`, from there. Get a shell there with
`sudo ip netns exec lepeer bash`; it shares this VM's programs, so install
`nmap` on this VM. Write answers to the files in `/root/lab-answers/`.

## Tasks

1. From the peer, scan this VM with `nmap -sV 10.99.0.1` and `nmap -sU
   --top-ports 20 10.99.0.1`, and compare with `ss -tulpn` here. Write
   the product and version nmap reports for port 22 to
   `/root/lab-answers/1`.
2. Find a CVE fixed in the `openssh-server` package, from its changelog,
   and write its ID (such as `CVE-2024-6387`) to `/root/lab-answers/2`.
   On the RHEL family, also list the security advisories.
3. RHEL family: install the SCAP scanner and content, find a CIS profile in
   the data stream for this system, and run a scan with it, writing the
   HTML report to `/root/cis.html`. It takes a few minutes.

## Hints

- `dnf install nmap` or `apt install nmap`; the `VERSION` column.
- `rpm -q --changelog openssh-server`, `dnf updateinfo list --security`;
  `apt changelog openssh-server`, or
  `/usr/share/doc/openssh-server/changelog.Debian.gz` (`zgrep`).
- `dnf install openscap-scanner scap-security-guide`,
  `/usr/share/xml/scap/ssg/content/`, `oscap info`, `oscap xccdf eval
  --profile ID --report FILE DATASTREAM`.
