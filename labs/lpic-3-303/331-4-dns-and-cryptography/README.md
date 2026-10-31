# LPIC-3 331.4: DNS and cryptography

BIND as an authoritative-only server for two made-up zones, one signed by
a `dnssec-policy` and one signed by hand, with trust anchors to validate
them, TSIG for transfers and updates, CAA and DANE records, and DNS over
TLS.

## Before you start

This VM is the authoritative server, at `10.99.0.1` (interface
`le-host`). The peer, at `10.99.0.2` (name `peer`), stands in for the
other VM and plays the client and validator: the lab checks your server
from there. Get a shell in the peer with `sudo ip netns exec lepeer bash`;
it shares this VM's files and programs.

The package is `bind` (with `bind-utils`) on the RHEL family and `bind9`
(with `bind9-dnsutils`) on Ubuntu. Keep your work files (sources of the
hand-signed zone, keys, certificates) in `/root/dns`. Where these tasks
say "the key file", they mean `/etc/named/lab-key.conf` on the RHEL family
and `/etc/bind/lab-key.conf` on Ubuntu. The firewall, if it's running, is
yours to open.

## Tasks

1. Install BIND and make it an authoritative-only server (no recursion
   for anyone), listening on `127.0.0.1` and `10.99.0.1`, and starting at
   boot. Serve the zone `lab.test` with an SOA, `NS ns1.lab.test.`, the
   CAA records `0 issue "letsencrypt.org"`, `0 issuewild ";"` and
   `0 iodef "mailto:security@lab.test"`, and A records for `ns1` and `www`
   pointing at `10.99.0.1`. Sign it with a `dnssec-policy` that has a
   separate KSK and ZSK (ECDSAP256SHA256) and uses NSEC3. Open the firewall
   for DNS if it's running.
2. Sign a second zone, `manual.test`, by hand with a KSK and a ZSK
   (`dnssec-keygen`, `dnssec-signzone`), with the same `NS` and A records
   (`ns1.manual.test.` and `www`, at `10.99.0.1`), and serve the signed
   file. Its denials use NSEC.
3. Make a TSIG key `lab-key` (HMAC-SHA256) in the key file. Allow zone
   transfers of `lab.test` only with it, and dynamic updates of `lab.test`
   only with it. Then add `mail.lab.test`, A `10.99.0.3`, with a signed
   dynamic update.
4. Write `/root/dns/lab-anchors.conf`, a `trust-anchors` block with a
   `static-ds` entry for each zone built from its KSK, so that, from the
   peer, `delv @10.99.0.1 -a /root/dns/lab-anchors.conf +root=lab.test
   www.lab.test` (and the same for `manual.test`) reports
   `fully validated`. Break `manual.test` once by editing an address in its
   signed file without re-signing, see validation fail, and fix it by
   signing again.
5. Publish DANE for a TLS service on port 4433: make a self-signed
   certificate for `www.lab.test` (`/root/dns/www.crt`, key
   `/root/dns/www.key`), add its `3 1 1` TLSA record at
   `_4433._tcp.www.lab.test` with a signed update, and serve it with
   `openssl s_server` on port 4433. Open the firewall for it if it's
   running.
6. Answer DNS over TLS on `10.99.0.1` port 853, so that
   `dig +tls @10.99.0.1 www.lab.test` works from the peer. Open the
   firewall for it if it's running.

## Hints

- RHEL family: `/etc/named.conf`, zones under `/var/named` (SELinux lets
  named write in `/var/named/dynamic`, which inline signing needs).
  Ubuntu: `/etc/bind/named.conf.options` and `named.conf.local`, zones
  under `/var/lib/bind`. `recursion no;`, `listen-on`, `named-checkconf
  -z`, `named-checkzone`, `rndc reload`.
- `dnssec-policy NAME { keys { ksk ...; zsk ...; }; nsec3param iterations
  0 optout no salt-length 0; };` and in the zone `dnssec-policy NAME;
  inline-signing yes;`; `rndc dnssec -status lab.test`;
  `dig @10.99.0.1 lab.test DNSKEY +dnssec +multi`.
- `dnssec-keygen -a ECDSAP256SHA256 [-f KSK] manual.test`,
  `dnssec-signzone -S -N INCREMENT -o manual.test manual.test.db`.
- `tsig-keygen -a hmac-sha256 lab-key`, `include` it, `allow-transfer {
  key lab-key; };`, `update-policy { grant lab-key zonesub ANY; };`;
  `dig -k KEYFILE ... AXFR`, `nsupdate -k KEYFILE`.
- `dig ... DNSKEY | dnssec-dsfromkey -f - ZONE`; an entry looks like
  `lab.test. static-ds 12345 13 2 "ABCD...";`. `rndc flush` doesn't matter
  here: `delv` validates for itself. `delv +cd`, `dig +cd` and
  `+dnssec` show more.
- `openssl req -x509 -newkey ec ...`; the TLSA data is the SHA-256 of the
  public key in DER: `openssl x509 -noout -pubkey | openssl pkey -pubin
  -outform DER | sha256sum`. `openssl s_server -accept 4433 -cert ... -key
  ... -www`, in the background; `openssl s_client -dane_tlsa_domain
  -dane_tlsa_rrdata`.
- `listen-on port 853 tls ephemeral { 10.99.0.1; };`; `firewall-cmd
  --add-service=dns --add-service=dns-over-tls`, or `ufw allow`.
