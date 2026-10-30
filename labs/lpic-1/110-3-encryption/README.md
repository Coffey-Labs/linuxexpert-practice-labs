# LPIC-1 110.3: Securing data with encryption

SSH keys and the agent, key-only logins, host keys, a tunnel, and GnuPG
encryption, signatures and revocation.

## Before you start

The lab creates users `alice` and `bob` (password `Lab-Pass-1`), and the
files `/home/alice/secret.txt` and `/home/alice/notes.txt`. Do each task as
the user it names: log in as them directly, on the console or with
`ssh alice@localhost` (after `su`, gpg often can't ask for a passphrase).

The peer, at `10.99.0.2` (name `peer`), is the second VM. It shares this
VM's users and home directories, but runs its own sshd
(`le-lab-peer-sshd.service`, which allows passwords for now) with its own
configuration and host keys. Get a root shell there with
`sudo ip netns exec lepeer bash`: in that shell, `/etc/ssh` is the peer's
(`/etc/netns/lepeer/ssh` seen from this VM). Restart its sshd with
`sudo systemctl restart le-lab-peer-sshd`.

## Tasks

1. As `alice`, make an ed25519 key with a passphrase, copy it to the peer
   with `ssh-copy-id alice@10.99.0.2`, and log in. Load it into an agent
   with `ssh-add` and log in again without typing the passphrase.
2. Turn off password logins on the peer, keeping one session open, and
   check in a new terminal that keys still work and passwords don't.
3. Compare the peer's host key fingerprint (`ssh-keygen -lf`) with the one
   your client showed. Then regenerate the peer's host keys (in the peer's
   shell: `rm /etc/ssh/ssh_host_*` and `ssh-keygen -A`, then restart its
   sshd), connect as `alice`, and read the warning. Then remove the old key
   from `alice`'s `known_hosts` and connect again.
4. Start a web server that listens only on the peer's localhost
   (`python3 -m http.server --bind 127.0.0.1 8000`, in the peer's shell),
   and reach it from this VM with `ssh -L`, so that
   `curl http://localhost:8000/` here shows its page while the tunnel is up.
5. Make GnuPG keys for `alice` (`Alice <alice@example.org>`) and `bob`
   (`Bob <bob@example.org>`), each with a passphrase, and exchange public
   keys. As `alice`, encrypt `secret.txt` for `bob` as
   `/home/alice/secret.txt.gpg`; as `bob`, decrypt it to
   `/home/bob/secret.txt`.
6. As `alice`, make a detached signature `/home/alice/notes.txt.sig` of
   `notes.txt` and check it. Then change one byte of `notes.txt`, and check
   again.
7. As `alice`, generate a revocation certificate for her key with
   `--generate-revocation`, import it, and look at `gpg -k`.

## Hints

- `ssh-keygen -t ed25519`; `eval "$(ssh-agent)"`, `ssh-add`, `ssh-add -l`.
- `PasswordAuthentication no` in the peer's `sshd_config`; test with
  `ssh -o PubkeyAuthentication=no alice@10.99.0.2`.
- `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`;
  `ssh-keygen -R 10.99.0.2`.
- Run the web server in the background (`&`) in the peer's shell;
  `ssh -N -f -L 8000:127.0.0.1:8000 alice@10.99.0.2`.
- `gpg --full-generate-key` or `--quick-generate-key`, `--export -a`,
  `--import`, `-e -r`, `-d -o`; copy files through `/tmp`.
- `gpg --detach-sign`, `gpg --verify notes.txt.sig notes.txt`.
- `gpg --output revoke.asc --generate-revocation alice@example.org`,
  `gpg --import revoke.asc`.
