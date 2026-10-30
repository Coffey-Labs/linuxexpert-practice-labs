# RHCSA 10.2: Default file permissions

A umask for one user, and a default umask for everyone.

## Before you start

The lab creates users `alice` and `bob` (password `Lab-Pass-1`), and notes
the files in `/etc/profile.d/` so reset can take out the ones you add.

## Tasks

1. Make new files of user `alice` readable and writable only by her,
   persistently: `su - alice -c 'umask; touch t; ls -l t'` prints `0077`
   and `-rw-------`.
2. Make every user's new directories `rwxr-x---` by default: for a user
   without their own umask line, `su - bob -c 'umask; mkdir d; ls -ld d'`
   prints `0027` and `drwxr-x---`. `alice` keeps her own umask.

## Hints

- `umask 077` in `~alice/.bashrc`.
- `umask 027` in a file in `/etc/profile.d/` ending in `.sh`. Don't edit
  `/etc/profile` or `/etc/bashrc`.
