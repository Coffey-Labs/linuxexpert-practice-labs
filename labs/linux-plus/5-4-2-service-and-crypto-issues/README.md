# Linux+ 5.4.2: Service, certificate and cipher problems

A service exposed to the network, a certificate for the wrong name, a key
exchange that can't be agreed, and a broken package repository.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for another machine: scan
this VM, `10.99.0.1`, from there (`sudo ip netns exec lepeer bash`; install
`nmap` on this VM). The lab has set up a few broken things:

- a service, `metrics-exporter`, configured in
  `/etc/metrics-exporter.conf`;
- a TLS test server, `le-lab-tls`, on port 8443, with its files in
  `/etc/le-lab/tls/`: the lab's own CA (`ca.crt`, `ca.key`) and the
  server's certificate and key (`server.crt`, `server.key`);
- something in the SSH client's configuration;
- on the RHEL family, a package repository.

Write answers to the files in `/root/lab-answers/`.

## Tasks

1. Find what's exposed on this VM, and compare with what the peer sees.
   One service listens on all addresses but is only meant for local
   monitoring tools: write its TCP port to `/root/lab-answers/1`, and make
   it listen on `127.0.0.1` only.
2. `curl --cacert /etc/le-lab/tls/ca.crt --resolve
   lab.example.test:8443:127.0.0.1 https://lab.example.test:8443/` fails.
   Write curl's exit code and the reason to `/root/lab-answers/2`. Then
   issue the server a new certificate for `lab.example.test`, signed by the
   lab's CA, and restart `le-lab-tls`, so the command works.
3. `ssh localhost` fails before it even asks how to log in. Find the
   setting that causes it, write the file it's in to
   `/root/lab-answers/3`, and fix it. Try the chapter's TLS 1.0 test
   against `www.kernel.org` too.
4. RHEL family: `dnf makecache` fails. Find the repository that breaks it,
   write its ID to `/root/lab-answers/4`, and disable or remove it.

## Hints

- `ss -tulpn`; from the peer, `nmap -sV 10.99.0.1`; `systemctl cat`.
- `curl -v`; `openssl x509 -noout -subject -ext subjectAltName`;
  `openssl req -new`, `openssl x509 -req -CA -CAkey -CAcreateserial
  -extfile` with `subjectAltName=DNS:...`.
- `ssh -v localhost`, `ssh -G localhost | grep kex`,
  `/etc/ssh/ssh_config.d/`.
- `dnf repolist`, `/etc/yum.repos.d/`, `enabled=0` or
  `dnf config-manager setopt ID.enabled=0`.
