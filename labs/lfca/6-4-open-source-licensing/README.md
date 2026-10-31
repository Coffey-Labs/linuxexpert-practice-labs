# LFCA 6.4: Open source software and licensing

Finding the licenses of installed packages, and signing off a commit.

## Before you start

Work as root (`sudo -i`), so `~` is `/root`. Answers go in
`/root/lab-answers/<task>`. The lab only checks that `~/practice-repo`
doesn't exist yet, and notes whether you already have a `~/.gitconfig` and
Git (reset removes the ones the lab didn't find).

## Tasks

1. Find the license of bash, curl, OpenSSL, SQLite and zlib from their
   package files, and say whether each is permissive, copyleft or public
   domain. Write one line per program to `/root/lab-answers/1`: the name in
   lowercase, a space, and the kind, such as `bash copyleft`.
2. Install Git if it's missing, set your name and email, create a practice
   repository `~/practice-repo`, make a commit with `git commit -s`, and
   look at the `Signed-off-by` line.

## Hints

- Ubuntu: the `Files: *` section of `/usr/share/doc/PACKAGE/copyright`.
  RHEL family: `rpm -q --qf '%{LICENSE}\n' PACKAGE`.
- Package names differ: `dpkg -S $(command -v curl)` or
  `rpm -qf $(command -v curl)` finds the one for a program. For a library
  with no program, `dpkg -S libz.so.1` or `rpm -qf /usr/lib64/libz.so.1`.
  SQLite's command-line tool may not be installed; its library is.
- `git config --global user.name`, `user.email`; `git init`,
  `git commit -s -m "..."`, `git log -1`.
