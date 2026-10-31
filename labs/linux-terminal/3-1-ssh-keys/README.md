# Using Linux Terminal 3.1: SSH keys

An Ed25519 key with a passphrase, installing it for another user by hand,
and what sshd does when a home directory is too open.

## Before you start

The lab creates user `student` (password `Lab-Pass-1`). Make the key as
`student` (`sudo -iu student`); use `sudo` for the steps that need root.
Give the key the passphrase `Lab-Phrase-1`: `le-lab check` needs it to
test the login. The lab checks that user `bob` doesn't exist yet, and
`le-lab reset` removes him and `~/.ssh/lab_key`.

## Tasks

1. Make an Ed25519 key pair with a passphrase and the comment `lab-key`,
   saved as `~/.ssh/lab_key`.
2. Create a user `bob` with a password, then install your lab key for him
   so you can log in to `bob@localhost` with it. Ubuntu cloud images turn
   off password logins over SSH, so ssh-copy-id can't log in there; use
   the manual steps instead. After `eval "$(ssh-agent)"; ssh-add
   ~/.ssh/lab_key`, `ssh -o BatchMode=yes -o
   StrictHostKeyChecking=accept-new -i ~/.ssh/lab_key bob@localhost
   whoami` prints `bob`.
3. Run `sudo chmod 777 /home/bob`, try the login again, and find out why it
   fails. Then fix it.

## Hints

- `ssh-keygen -t ed25519 -C lab-key -f ~/.ssh/lab_key`; `ssh-keygen -l -f`.
- `useradd -m`, `passwd`; then `/home/bob/.ssh` (mode 700) and
  `authorized_keys` (mode 600), both owned by `bob`, holding the `.pub`
  line. BatchMode doesn't ask about a new host key either: without
  `accept-new`, the first try fails with "Host key verification failed."
- `journalctl -u ssh -n 5` or `/var/log/auth.log`: "bad ownership or
  modes"; `chmod 750 /home/bob`.
