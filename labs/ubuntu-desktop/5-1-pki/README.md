# Ubuntu Desktop 5.1: PKI on the desktop

Reading a web site's certificate, making your own CA and a server
certificate signed by it, trusting the CA system-wide, and taking it out
of the trust store again.

## Before you start

The lab makes an empty folder `/root/pki` to work in, makes sure
`openssl` and `curl` are installed, and adds a small hook to
`update-ca-certificates` that notes which certificates it adds, so the
check can see that task 2 was done after task 3 undoes it. The VM needs
to reach `ubuntu.com`. Write answers to the files in `/root/lab-answers/`.

## Tasks

1. Find which CA issued the certificate of `ubuntu.com`, and when it
   expires. Write the issuer's organization (or its CN) on line 1 of
   `/root/lab-answers/1` and the expiry date on line 2.
2. In `/root/pki`, make a root CA (`ca.crt`, `ca.key`) and a server
   certificate for `localhost` signed by it (`server.crt`, `server.key`),
   serve it with `openssl s_server -accept 4433 -cert server.crt -key
   server.key -www`, and make curl trust it system-wide.
3. Remove your CA from the system trust store again, and see curl fail.

## Hints

- `openssl s_client -connect ubuntu.com:443 -servername ubuntu.com
  </dev/null 2>/dev/null | openssl x509 -noout -issuer -enddate`.
- `openssl req -x509 -newkey ...` for the CA; `openssl req -newkey` and
  `openssl x509 -req -CA ca.crt -CAkey ca.key` for the server, with
  `subjectAltName=DNS:localhost`. Copy `ca.crt` to
  `/usr/local/share/ca-certificates/` (the name must end in `.crt`) and
  run `update-ca-certificates`; `curl https://localhost:4433/` then works
  without `--cacert`.
- Delete the file and run `update-ca-certificates --fresh`; curl now
  fails with `curl: (60) SSL certificate problem`.
