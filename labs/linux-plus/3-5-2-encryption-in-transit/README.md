# Linux+ 3.5.2: Encrypting data in transit

Inspecting a TLS server, the system-wide crypto policy, and seeing a
clear-text protocol on the wire.

## Before you start

Task 1 needs the internet. Nothing else is set up: write answers to the
files in `/root/lab-answers/`.

## Tasks

1. Connect to `www.kernel.org:443` with `openssl s_client` and look at the
   certificate chain, protocol and cipher; then try again allowing only
   TLS 1.1, and see it fail. Write the protocol version the first
   connection used (as `openssl` shows it) to `/root/lab-answers/1`.
2. RHEL family: look at the system-wide crypto policy and what it allows
   in OpenSSL. Write the name of the current policy to
   `/root/lab-answers/2`.
3. Run a web server on `127.0.0.1:8000` and capture the traffic on the
   loopback interface while you send it a request with the header
   `Authorization: Basic c2VjcmV0` with curl. Save the capture to
   `/root/lab-answers/3.pcap` and read the header back from it.

## Hints

- `openssl s_client -connect HOST:443 -servername HOST </dev/null`, the
  `Protocol` line; `-tls1_1`.
- `update-crypto-policies --show`;
  `/etc/crypto-policies/back-ends/opensslcnf.config`.
- `python3 -m http.server 8000 --bind 127.0.0.1 &`; `tcpdump -i lo -A
  port 8000`, `-w FILE`, `-r FILE`; `curl -H`. tcpdump may switch to its
  own user before it writes the file: add `-Z root`.
