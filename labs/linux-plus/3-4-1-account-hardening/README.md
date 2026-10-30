# Linux+ 3.4.1: Hardening accounts

Password aging, password quality, locking and expiring an account, and
auditing the accounts of a system.

## Before you start

User `hardtest` doesn't exist yet: you create it. The lab has also added
two accounts that an audit should catch. Write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Read the current rules in `pwquality.conf`, `login.defs` and
   `faillock.conf`. Create user `hardtest`, and set its password aging:
   at most 90 days, at least 1 day, a warning 7 days before. Then make it
   change its password at the next login.
2. Ubuntu: install `libpam-pwquality`, so that `passwd` judges new
   passwords. Try `passwd hardtest` with the password `password1` (Ctrl+C
   to stop). On the RHEL family, `passwd` uses pwquality already: just try
   it.
3. Lock `hardtest`'s password and expire the account, and look at its
   shadow entry and `chage -l`.
4. Audit the system: find the accounts other than root with UID 0, and the
   accounts with an empty password. Write their names, one per line, to
   `/root/lab-answers/4`.

## Hints

- `useradd -m`, `chage -M -m -W`, `chage -d 0`, `chage -l`.
- `/etc/pam.d/common-password`.
- `passwd -l`, `chage -E 0`, `grep hardtest /etc/shadow`.
- `awk -F: '$3 == 0' /etc/passwd`, `awk -F: '$2 == ""' /etc/shadow`,
  `lastlog -b 30`.
