# Linux+ 2.2.2: Locking, expiry and who's who

Password aging, forcing a password change, locking and expiring an
account.

## Before you start

The lab only checks that user `agetest` doesn't exist yet. Don't remove
`agetest` at the end: the lab grades it, and `le-lab reset` removes it.

## Tasks

1. Create user `agetest` with a home directory and the password
   `Lab-Pass-123`, and look at its password aging and the defaults in
   `/etc/login.defs`.
2. Force `agetest` to change the password at the next login, and see it
   happen with `su - agetest` (press Ctrl+C at the new-password prompt).
3. Lock `agetest`'s password and check its status, then unlock it again.
   Finally, expire the account itself (expiry day 0).

## Hints

- `useradd -m`, `chpasswd`, `chage -l`, `grep '^PASS_' /etc/login.defs`.
- `chage -d 0`.
- `passwd -l`, `passwd -S`, `passwd -u`, `chage -E 0`, `chage -l`.
- The chapter's step 4 (who's who) isn't graded: try `id`, `groups`, `who`,
  `w`, `last -n 5` and `lastb -n 5` (or `lslogins --failed`) anyway.
