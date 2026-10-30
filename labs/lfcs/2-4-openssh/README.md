# LFCS 2.4: OpenSSH

Who may log in and how, a second port, client aliases, tunnels, and an
SFTP-only chroot.

## Before you start

The lab creates users `alice` (in group `sshusers`), `bob` (not in it) and
`sam` (in group `sftponly`), with key pairs in `/root/lab-keys/` whose
public halves are in their `authorized_keys`. It adds you to `sshusers` too,
so you can still log in after task 1; log in with a key, not a password,
and keep a console or second session open while you change sshd.

The peer, at `10.99.0.2` (name `peer`), stands in for another VM. It runs
its own sshd, sharing this VM's users and `/etc/ssh`, and a web server that
listens only on its own `127.0.0.1:80`. Get a shell there with
`sudo ip netns exec lepeer bash`.

## Tasks

1. Allow SSH logins only with keys, never as root, and only for members of
   group `sshusers`.
2. Make sshd listen on port 2222 as well as 22 (with SELinux enforcing on
   the RHEL family).
3. As root, set up a client alias so `ssh lab` logs in to the peer as
   `alice` with the key `/root/lab-keys/alice`, without asking for a
   password.
4. Reach the peer's web server (its `127.0.0.1:80`) from this VM through an
   SSH tunnel, so `curl localhost:8080` here returns its page while the
   tunnel is up.
5. Restrict group `sftponly` to SFTP in a chroot under `/srv/sftp/<user>`,
   with a directory `upload` there that the user can write to. If task 1's
   `AllowGroups sshusers` is set, members need to be in `sshusers` too.

## Hints

- A drop-in in `/etc/ssh/sshd_config.d/` that sorts first; `ls` that
  directory, then `sshd -t` and `sshd -T`.
- RHEL: `semanage port`. Ubuntu: `ssh.socket`, `systemctl daemon-reload`.
- `~/.ssh/config` with `Host`, `HostName`, `User`, `IdentityFile`.
- `ssh -N -f -L`.
- `Match Group`, `ChrootDirectory`, `ForceCommand internal-sftp`; the
  chroot directory must be owned by root. Test with
  `sftp -i /root/lab-keys/sam sam@localhost`.
