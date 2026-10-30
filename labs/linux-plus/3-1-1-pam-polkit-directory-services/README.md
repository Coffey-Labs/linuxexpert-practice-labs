# Linux+ 3.1.1: PAM, polkit and directory services

Reading a PAM stack, blocking logins with `pam_nologin`, and looking at a
polkit action.

## Before you start

The lab creates user `pat` (password `Lab-Pass-1`), a normal account that
can log in over SSH. Write answers to the files in `/root/lab-answers/`.
Task 2 blocks new logins for everyone but root for a while: keep a root
shell open (`sudo -i`) until you've removed the block.

## Tasks

1. Read sshd's PAM stack in `/etc/pam.d/sshd`. Its `auth` lines hand over
   to a shared file of the system (with `substack` on the RHEL family,
   `@include` on Ubuntu). Write that file's name to `/root/lab-answers/1`.
   On the RHEL family, also see what `authselect current` says.
2. Block logins for everyone but root with `pam_nologin`, with the message
   `Maintenance until 11:00`. Try `ssh pat@localhost` and save what it
   prints to `/root/lab-answers/2`. Then remove the block, so that pat can
   log in again.
3. Look at the polkit actions with `pkaction`. Find the authorization
   that `org.freedesktop.systemd1.manage-units` needs from a user in an
   active local session, and write it to `/root/lab-answers/3`. If you
   like, try `pkexec id` too (on Ubuntu, install `pkexec` first).
4. If you have an AD or FreeIPA test domain, run `realm discover` and
   `realm join` against it, then `id` a domain user. If not, read
   `man sssd.conf` and `man realm`. Not graded.

## Hints

- `cat /etc/pam.d/sshd`; `authselect current`.
- `/etc/nologin`; `ssh pat@localhost 2>&1 | tee /root/lab-answers/2`.
- `pkaction --verbose --action-id ...`, the `implicit active:` line.
