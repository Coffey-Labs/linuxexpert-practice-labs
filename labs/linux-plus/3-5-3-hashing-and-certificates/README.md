# Linux+ 3.5.3: Hashing and certificates

A checksum that catches a change, a private CA and a server certificate it
signs, and trusting the CA system-wide.

## Before you start

Nothing is set up. Work as root (`sudo -i`), in root's home directory
`/root`, so the files are where the check looks: `/root/f.txt`,
`/root/f.sha256` and `/root/pki/`.

## Tasks

1. Write `version 1` to `f.txt`, save its SHA-256 checksum in
   `f.sha256`, and check it. Then change the file to `version 2` and see
   the check fail. Leave it like that.
2. In `/root/pki`, make a private CA (`ca.key`, `ca.crt`, subject
   `CN=Lab CA`), and a server key and certificate (`www.key`, `www.crt`)
   for `lab.example.test`, with that name in its subject alternative names,
   signed by the CA. Verify the certificate against the CA.
3. Serve the certificate with `openssl s_server` on port 8443 and see curl
   reject it, then accept it with `--cacert`. Then add the CA to the
   system's trust store, and see curl accept it without `--cacert`.

## Hints

- `sha256sum FILE > FILE.sha256`, `sha256sum -c`.
- `openssl req -x509 -newkey rsa:3072 -nodes`, `openssl req -new`,
  `openssl x509 -req -CA -CAkey -CAcreateserial -extfile` with
  `subjectAltName=DNS:...`; `openssl verify -CAfile`.
- `curl --resolve lab.example.test:8443:127.0.0.1`. RHEL family:
  `/etc/pki/ca-trust/source/anchors/` and `update-ca-trust`; Ubuntu:
  `/usr/local/share/ca-certificates/` (the name must end in `.crt`) and
  `update-ca-certificates`.
