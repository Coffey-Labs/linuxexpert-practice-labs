# LPIC-3 335.1: Common security vulnerabilities and threats

Four threats and the controls that stop them, on a machine you own: a
buffer overflow, an SQL injection, password hashes, and a small honeypot
that logs a scanner on the peer.

## Before you start

Setup made `/root/threats` with `greet.c`, a small program that copies
its first argument into a 16-byte buffer with no length check. It also
made a user `hashdemo` with a password. The peer, at `10.99.0.2` (name
`peer`), plays the scanner; it sits on this VM's second network, where
this VM is `10.99.0.1` on interface `le-host`. Run commands there with
`sudo ip netns exec lepeer COMMAND`.

The firewall, if it's running, is yours to open. Work in `/root/threats`.
The honeypot only runs until you stop it or reboot.

## Tasks

1. Install a C compiler. Build `greet` from `greet.c` with
   `-O0 -fstack-protector-strong`, and `greet-fortify` with
   `-O2 -D_FORTIFY_SOURCE=2`. Both must greet `Alice` normally; given 64
   characters, `greet` must die with `stack smashing detected` and
   `greet-fortify` with `buffer overflow detected`. Write the system's
   ASLR setting (`kernel.randomize_va_space`) to `/root/lab-answers/1`.
2. Make `users.db`, an SQLite database with a table `users(name, secret)`
   holding the users `alice` and `bob`. Write `lookup.py`, which takes a
   name and prints the matching rows twice: first from a query built as a
   string (`string-built: ...`), then from a parameterized query
   (`parameterized: ...`). The name `x' OR '1'='1` must return every row
   from the first and none from the second.
3. Find the hashing method of `hashdemo`'s password and write its marker
   from `/etc/shadow` (the part between the first two `$` signs, with
   them, like `$1$`) to `/root/lab-answers/3`.
4. Run a fake Telnet honeypot on `10.99.0.1` port 2323: it answers each
   connection with a login prompt (one that says `login:`) and appends a
   line to `/root/threats/honeypot.log` with the client's address and
   what it sent.
5. From the peer, install the tools and play the attacker: scan ports 22,
   23 and 2323 of `10.99.0.1` with nmap and save the output in
   `/root/threats/scan.txt`, then try to log in to the honeypot as `root`
   and as `admin`. Find the MAC address that answers ARP for `10.99.0.1`
   on the peer and write it to `/root/lab-answers/5`.

## Hints

- `gcc`; `./greet "$(printf 'A%.0s' {1..64})"`;
  `cat /proc/sys/kernel/randomize_va_space`.
- `sqlite3` (`sqlite` on RHEL relatives), or Python's `sqlite3` module.
  An f-string query versus `db.execute("... WHERE name = ?", (name,))`.
- `getent shadow hashdemo`. Never print a real password.
- `socket.bind(("10.99.0.1", 2323))`, `listen()`, `accept()`, `sendall`,
  `recv`, and a log file opened with `buffering=1`; `setsid -f python3
  honeypot.py`; `ss -ltn`.
- `nmap` and `nc` (`nmap-ncat` on RHEL relatives, `netcat-openbsd` on
  Ubuntu), `arping` (`iputils-arping` on Ubuntu); `ip neigh`. As root,
  nmap sends a SYN scan, which never completes a connection, so the
  honeypot doesn't see it; `-sT` makes full connections it will log.
- `printf 'root\r\n' | nc -w 3 10.99.0.1 2323`.
