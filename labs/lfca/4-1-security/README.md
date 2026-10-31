# LFCA 4.1: Security

SSH keys without passwords, a host firewall that allows only SSH, hashes,
encrypting a file with a passphrase, and looking up a CVE.

## Before you start

Work as root (`sudo -i`), so `~` is `/root`. Answers go in
`/root/lab-answers/<task>`. Keep a console session open while you change
SSH or firewall settings.

The lab creates user `alice` (password `Lab-Pass-1`), the files
`/root/hash-me.txt` and `/root/secret.txt`, and a web server on port 8080.
The peer, at `10.99.0.2` (name `peer`), stands in for another machine; this
VM is `10.99.0.1` there. Get a shell there with
`sudo ip netns exec lepeer bash`. The lab saves the SSH and firewall
settings, and reset puts them back.

## Tasks

1. Set up SSH key login from root to `alice` on this VM (`ssh
   alice@localhost` logs in without a password). Then set
   `PasswordAuthentication no` in a file such as
   `/etc/ssh/sshd_config.d/10-no-passwords.conf`, check it with
   `sshd -T | grep -i passwordauth`, reload the SSH service, and check that
   passwords no longer work.
2. Turn on the host firewall (firewalld on the RHEL family, ufw on
   Ubuntu) and allow only SSH. Confirm that the web server on port 8080 can
   no longer be reached from the peer.
3. Take the `sha256sum` of `/root/hash-me.txt`, change one character in
   it, and take it again. Write the two hashes to `/root/lab-answers/3`,
   one per line, before and after.
4. Encrypt `/root/secret.txt` with a passphrase (`gpg -c`), delete the
   original, then decrypt `/root/secret.txt.gpg` back to
   `/root/secret.txt`.
5. Look up CVE-2024-3094 in the NVD (nvd.nist.gov) and write its CVSS base
   score to `/root/lab-answers/5`.

## Hints

- `ssh-keygen`, `ssh-copy-id alice@localhost`. The drop-in's name must end
  in `.conf` and sort before any `50-cloud-init.conf`: sshd uses the first
  value it reads. `systemctl reload sshd` (`ssh` on Ubuntu). Test with
  `ssh -o PubkeyAuthentication=no alice@localhost`.
- `dnf install firewalld`, `systemctl enable --now firewalld`,
  `firewall-cmd --list-all`, `--remove-service`, `--remove-port`,
  `--permanent`, `--reload`. `ufw allow OpenSSH`, `ufw enable`. From the
  peer: `curl --max-time 5 http://10.99.0.1:8080/`.
- `sha256sum FILE`; any editor, or `sed -i 's/quick/quack/'`.
- `gpg -c /root/secret.txt`, `rm`, `gpg -o /root/secret.txt -d
  /root/secret.txt.gpg`. If it doesn't ask for the passphrase, that's
  gpg's cache: run `gpgconf --reload gpg-agent` first.
- The score is on the CVE's NVD page, next to its severity.
