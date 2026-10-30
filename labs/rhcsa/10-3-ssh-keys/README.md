# RHCSA 10.3: SSH key-based authentication

Key-based login to another system, turning off password logins there, and
what sshd does when `authorized_keys` is too open.

## Before you start

The lab creates users `student` and `alice` (password `Lab-Pass-1`), and a
second machine, `server1` (`10.99.0.2`), to log in to. `server1` shares
this VM's files and users, and runs its own sshd, with its own
configuration so this VM's SSH logins aren't touched:

- configuration: `/etc/ssh/server1/sshd_config`, which reads
  `/etc/ssh/server1/sshd_config.d/*.conf` first;
- service: `le-lab-server1-sshd` (restart it after a change, and read its
  log with `journalctl -u le-lab-server1-sshd`);
- test the configuration with `sshd -t -f /etc/ssh/server1/sshd_config`
  and `sshd -T -f /etc/ssh/server1/sshd_config`.

`server1` allows password logins to start with.

## Tasks

1. Set up key-based login for user `student` to user `alice` on `server1`:
   as `student`, `ssh -o BatchMode=yes alice@server1 whoami` prints
   `alice` without asking anything.
2. Turn off password logins for SSH on `server1`, and confirm keys still
   work: `ssh -o PubkeyAuthentication=no alice@server1` fails with
   "Permission denied (publickey...)".
3. Make `alice`'s `authorized_keys` writable by her group (mode `620`), and
   see what happens to the key login and in sshd's log; then fix it.

## Hints

- As `student` (`su - student`): `ssh-keygen`, then
  `ssh-copy-id alice@server1` (alice's password is `Lab-Pass-1`).
- `PasswordAuthentication no` in a file in
  `/etc/ssh/server1/sshd_config.d/`; `systemctl restart
  le-lab-server1-sshd`; `sshd -T -f /etc/ssh/server1/sshd_config | grep
  -i passwordauthentication`.
- `chmod 620 ~alice/.ssh/authorized_keys`; `journalctl -u
  le-lab-server1-sshd` shows "bad ownership or modes"; `chmod 600`.
