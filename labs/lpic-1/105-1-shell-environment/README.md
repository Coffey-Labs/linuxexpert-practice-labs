# LPIC-1 105.1: Customizing the shell environment

A personal `bin` directory in `PATH`, a shell function kept in `~/.bashrc`,
and the skeleton files new users get.

## Before you start

The lab creates user `alice` (password `Lab-Pass-1`). Do tasks 1 and 2 as
`alice`: log in as her, or run `sudo -iu alice`.

## Tasks

1. As `alice`, make sure `~/bin` is in her `PATH` permanently, and put an
   executable script called `hello` there that prints a greeting. A new
   login shell must run it by name: `sudo -iu alice hello`.
2. Write the `mkcd` function (make a directory, then change into it) and
   keep it in `alice`'s `~/.bashrc`, so that it works in every new
   interactive shell of hers.
3. Put a file called `welcome.txt` in `/etc/skel`, then create user `newbie`
   with `useradd -m`, and check that the file is in the new home directory.

## Hints

- `echo "$PATH"`, `command -v hello`; `~/.profile` or `~/.bash_profile`,
  and what the distribution's own startup files already do with `~/bin`.
- `#!/bin/bash`, `chmod +x`.
- `mkcd() { mkdir -p "$1" && cd "$1"; }`; test in a new shell with
  `type mkcd`. A script can't do the same: why?
- `ls -A /etc/skel`, `useradd -m`, `ls -la ~newbie`.
