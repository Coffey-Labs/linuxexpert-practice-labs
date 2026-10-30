# LFCS 5.2: Environment profiles

Setting variables, PATH entries and aliases in the right startup files: for
everyone, for one user, and for users created later.

## Before you start

The lab creates users `erin` and `frank` (password `Lab-Pass-1`, shell
bash) and a directory `/opt/tools/bin` with a small tool in it. So that
`le-lab check` can test `ssh` sessions, it puts a lab key in their
`~/.ssh/authorized_keys`. Reset puts `/etc/skel`, `/etc/profile.d`,
`/etc/environment`, the system bashrc and root's own startup files back as
they were.

## Tasks

1. Set `COMPANY=example` for every user's login shell, without editing
   `/etc/profile`. Test it with `sudo -iu erin printenv COMPANY`.
2. Give every new user an alias `lt='ls -ltr'` and a `README` file in their
   home directory. Test it with `useradd -m testuser`, then
   `sudo -iu testuser bash -ic 'alias lt'` and `ls /home/testuser`; remove
   `testuser` again afterwards.
3. Add `/opt/tools/bin` to `erin`'s `PATH` permanently, and only to hers:
   `frank`'s `PATH` must not have it.
4. Set `HTTP_PROXY=http://proxy.example.org:3128` for every session,
   including `ssh host command`. Test it with
   `ssh erin@localhost printenv HTTP_PROXY`.

## Hints

- `/etc/profile.d/*.sh`; check with `sudo -iu USER printenv`.
- `/etc/skel` and the `.bashrc` in it; `useradd -m`.
- `~/.bash_profile` (RHEL family) or `~/.profile` (Debian, Ubuntu).
- `/etc/environment`, read by `pam_env`; no `export`, no `$VARIABLES`.
