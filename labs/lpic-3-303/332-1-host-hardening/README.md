# LPIC-3 332.1: Host hardening

File capabilities, USBGuard, an SSH certificate authority for host and
user certificates with a revocation list, and a small chroot jail.

## Before you start

The lab creates the user `certuser` (password `Lab-Pass-1`), with no
`authorized_keys`, for tasks 4 and 5. Keep the SSH CA and the user key in
`/root/sshca`, with the file names the tasks give. You change sshd's
configuration in tasks 3 to 5: keep a second session open while you do,
and check with `sshd -t` before you reload. Your own logins don't change.

The chapter's GRUB password, polkit, ASLR, systemd sandboxing and CPU
vulnerability steps are for looking around; try them, but they aren't
graded here.

## Tasks

1. Copy the Python interpreter (the real file, not a link) to
   `/usr/local/bin/lab-python`, and give the copy the file capability that
   lets an ordinary user bind ports below 1024 with it. Check that
   `python3` still can't.
2. Install USBGuard, generate a policy that allows the devices attached
   now as `/etc/usbguard/rules.conf` (mode 600), and run the daemon,
   enabled at boot. Try blocking and allowing a device again.
3. Make an SSH CA, `/root/sshca/ca` (with `ca.pub`), and give sshd a host
   certificate for its ED25519 host key, signed by the CA for the name
   `localhost`, so that a client that trusts only the CA
   (`@cert-authority localhost ...` in its known-hosts file) connects
   without a prompt.
4. Make sshd trust the CA for user certificates. Make a key pair
   `/root/sshca/user` for `certuser`, sign a one-hour certificate for it
   (`user-cert.pub`, principal `certuser`), and log in as `certuser` with
   it.
5. Revoke `/root/sshca/user.pub` with a key revocation list,
   `/etc/ssh/revoked.krl`, that sshd uses, so that login is refused. Other
   certificates from the CA must still work.
6. Build a chroot jail in `/srv/jail` with `/bin/bash` and `/bin/ls` and
   the libraries they need, so that `chroot /srv/jail /bin/bash -c 'ls /bin'`
   works.

## Hints

- `readlink -f "$(command -v python3)"`; `setcap cap_net_bind_service=ep`,
  `getcap`. Test as an ordinary user: `sudo -u nobody /usr/local/bin/lab-python
  -c 'import socket; socket.socket().bind(("127.0.0.1", 80))'`. `capsh
  --decode`, `/proc/self/status`.
- `usbguard generate-policy`, `systemctl enable --now usbguard`,
  `usbguard list-devices`, `usbguard block-device`, `usbguard
  allow-device`; each device's `authorized` file under `/sys/bus/usb/devices`.
- `ssh-keygen -t ed25519 -f ca`; `ssh-keygen -s ca -I ID -h -n localhost
  -V +52w /etc/ssh/ssh_host_ed25519_key.pub`; `HostCertificate` in a file in
  `/etc/ssh/sshd_config.d/`; `ssh-keyscan -c localhost`.
- `TrustedUserCAKeys`; `ssh-keygen -s ca -I ID -n certuser -V +1h user.pub`,
  `ssh-keygen -L -f user-cert.pub`; `ssh -i /root/sshca/user certuser@localhost`.
- `ssh-keygen -k -f revoked.krl user.pub`, `ssh-keygen -Q -f revoked.krl
  user.pub`; `RevokedKeys`.
- `cp --parents`, `ldd`, `cp -L`.
