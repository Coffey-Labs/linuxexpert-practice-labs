# Using Linux Terminal 3.3: Password complexity and expiry

Password rules with pam_pwquality, aging and account expiry for one user,
and aging defaults for new accounts.

## Before you start

Work as root (`sudo -i`). The lab creates users `alice` and `pwtest`
(password `Lab-Pass-1`); try passwords out on `pwtest`, for example `echo
'pwtest:lowercase12' | chpasswd`, so alice's settings from task 2 stay as
you made them. The rules only apply when a password is set, so they can't
lock anyone out of logging in. The lab saves `/etc/pam.d/common-password`,
the pwquality settings and `/etc/login.defs`, and puts them back on reset;
reset also removes `libpam-pwquality` again if the lab started without it,
and user `dave` if you made him.

## Tasks

1. Install pam_pwquality and require passwords of at least 10 characters
   with at least one digit and one uppercase letter, for every user
   including root. `echo 'pwtest:lowercase12' | chpasswd` fails with "BAD
   PASSWORD: The password contains less than 1 uppercase letters", and
   `echo 'pwtest:Kettle7-Harbor' | chpasswd` succeeds.
2. Make alice's password expire every 60 days with 10 days' warning,
   disable her account on the last day of next year, and make her choose a
   new password at her next login.
3. Make new accounts' passwords expire after 120 days, without changing
   existing users. After `useradd -m dave`, `chage -l dave` shows maximum
   120, and `chage -l alice` is unchanged.

## Hints

- `apt install libpam-pwquality`; a file in
  `/etc/security/pwquality.conf.d/` (make the directory) with `minlen`,
  `dcredit = -1`, `ucredit = -1` and `enforce_for_root`.
- `chage -M -W -E -d 0`; check with `chage -l alice`.
- `PASS_MAX_DAYS` in `/etc/login.defs`.
