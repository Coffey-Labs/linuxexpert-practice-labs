# LFCS 4.6: SSL and TLS certificates

A self-signed certificate, HTTPS in nginx, a private CA, system trust, and
reading a public site's certificate.

## Before you start

The lab installs nginx (running, HTTP only), points `web1.example.org` and
`www.example.org` at this VM in `/etc/hosts`, and creates `/root/tls/` for
your keys and certificates. Keep the files the tasks name there; copy them
wherever nginx needs them. Write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Create a 3072-bit RSA key and a self-signed certificate valid for 365
   days for `web1.example.org`, with that name and `www.example.org` as
   subject alternative names: `/root/tls/web1-self.key` and
   `/root/tls/web1-self.crt`.
2. Serve HTTPS for `web1.example.org` from nginx with it, redirecting HTTP
   to HTTPS.
3. Create a private CA (`/root/tls/ca.crt`), sign a new certificate for
   `web1.example.org` with it (`/root/tls/web1.crt`), and use that
   certificate in nginx instead.
4. Make the system trust the CA.
5. Find out when the certificate of `www.kernel.org` expires, and write the
   date to `/root/lab-answers/5`.

## Hints

- `openssl req -x509 -newkey rsa:3072 -noenc -days ... -subj ...
  -addext subjectAltName=...`;
  `openssl x509 -in web1-self.crt -noout -dates -ext subjectAltName`.
- `ssl_certificate`, `ssl_certificate_key`, `return 301 https://...`;
  `nginx -t`. On RHEL, `restorecon` for files moved into `/etc/pki/tls/`.
  `curl -sI http://web1.example.org/`.
- `openssl req -new`, `openssl x509 -req -CA ca.crt -CAkey ca.key
  -CAcreateserial -copy_extensions copy`; `openssl verify -CAfile ca.crt
  web1.crt`.
- `/etc/pki/ca-trust/source/anchors/` and `update-ca-trust`, or
  `/usr/local/share/ca-certificates/` and `update-ca-certificates`;
  `curl https://web1.example.org/`.
- `openssl s_client -connect ... -servername ... </dev/null | openssl x509
  -noout -enddate`.
