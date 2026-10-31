# Ubuntu Server 3.1: Remote SSH access

Who may log in over SSH, key-only logins in a drop-in that wins, and a
second port.

## Before you start

The lab only saves the SSH configuration, so reset can put it back. Start
it with `sudo` from your own account: task 1 lets in only one group, and
your account must be in it. Keep a second SSH session or the console open
while you change sshd, in case you lock yourself out.

"Your key" is a key pair of your own account on this VM, in `~/.ssh/`;
make one with `ssh-keygen` if you have none. Leave its passphrase empty,
so the check can log in with it as you.

## Tasks

1. Create users `ann` and `ben`, each with a password and your key in
   `authorized_keys`. Allow SSH logins only for members of a new group
   `remote`, and put ann and your own account in it, but not ben.
   `ssh -o BatchMode=yes ann@localhost true` works; the same for ben fails,
   and `sudo journalctl -u ssh` says ben's groups aren't listed in
   AllowGroups.
2. Turn off password logins for everyone, and root logins completely, in a
   drop-in that wins over the cloud image's own files.
   `ssh -o PubkeyAuthentication=no ann@localhost` fails with `Permission
   denied (publickey)`.
3. Make sshd listen on port 2222 as well as 22. `ss -tln` lists `:2222`,
   and `ssh -p 2222 ann@localhost true` works.

## Hints

- `useradd -m -s /bin/bash`, `passwd`; `install -d -m 700 -o ann -g ann`
  `~ann/.ssh`, then `authorized_keys` with mode 600, owned by the user.
  `groupadd`, `usermod -aG`; `AllowGroups`.
- `ls /etc/ssh/sshd_config.d/`: the first value sshd reads wins, so give
  your file a name that sorts first. `sudo sshd -t`, `sudo sshd -T | grep
  -E '^(passwordauthentication|permitrootlogin)'`, `systemctl reload ssh`.
- `Port 22` and `Port 2222`; on 24.04 `ssh.socket` owns the port:
  `systemctl daemon-reload`, `systemctl restart ssh.socket`.
