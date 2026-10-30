# RHCSA 9.2: Passwords and password aging

Setting a password that must be changed, the default password lifetime for
new users, and account expiry.

## Before you start

The lab creates user `dave` (password `Lab-Pass-1`), and notes
`/etc/login.defs` so reset can put it back.

## Tasks

1. Give user `dave` the password `Secret-2026` and make him change it at
   the next login.
2. Make passwords of users created from now on expire after 90 days,
   without changing existing users.
3. Make `dave`'s account expire on 31 December 2027, with a 14-day warning
   before his password expires.

## Hints

- `passwd dave` (or `chpasswd`), `chage -d 0` (or `passwd -e`);
  `chage -l dave`; `su - dave` from a normal user asks for a new password.
- `PASS_MAX_DAYS` in `/etc/login.defs`; create a test user and run
  `chage -l` on it, then remove it.
- `chage -E 2027-12-31 -W 14 dave`.
