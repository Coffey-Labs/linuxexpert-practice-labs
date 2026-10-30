# Linux+ 3.3.4: Secure remote access with SSH

A key pair, key-only logins, and a local port forward.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for the Ubuntu VM, the
client; this VM, `10.99.0.1` from the peer, is the server. Get a shell
there with `sudo ip netns exec lepeer bash`. The peer shares this VM's
files and users, so a key made there is in the same home directory.

The lab creates user `kim` (password `Lab-Pass-1`): work as kim on both
sides, for example with `sudo ip netns exec lepeer su - kim`. It also runs
a small web service on this VM's `127.0.0.1:9090` only, standing in for
Cockpit.

Task 2 turns off password logins on this VM: log in with a key yourself,
and keep a second session or a console open while you change sshd.

## Tasks

1. As kim on the peer, make an ed25519 key pair `~/.ssh/lab_ed25519`
   without a passphrase, install it for kim on this VM with `ssh-copy-id`
   (to `kim@10.99.0.1`), and log in with it. Look at the permissions of
   `~/.ssh` and `authorized_keys`.
2. On this VM, turn off password and keyboard-interactive logins and root
   logins, in a drop-in that wins over the other files in
   `/etc/ssh/sshd_config.d/`. Check the configuration, reload sshd, and
   check what sshd uses.
3. From the peer, a password login as kim is now refused, and the key
   still works.
4. As kim on the peer, forward the peer's local port 19090 to port 9090
   on this VM's own localhost, through SSH with the key, in the
   background. `curl http://localhost:19090/` on the peer returns the
   page.

## Hints

- `ssh-keygen -t ed25519 -f ~/.ssh/lab_ed25519 -N ''`, `ssh-copy-id -i`,
  `ssh -i`.
- Files in `sshd_config.d` are read in name order and the first value
  wins: `ls /etc/ssh/sshd_config.d/`. `sshd -t`, `sshd -T | grep -iE
  '^(passwordauth|kbdinter|permitroot)'`; `systemctl reload sshd` (`ssh`
  on Ubuntu).
- `ssh -o PubkeyAuthentication=no`.
- `ssh -N -f -L 19090:localhost:9090`.
