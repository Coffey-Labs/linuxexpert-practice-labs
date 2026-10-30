# Linux+ 1.5.1: The shell environment

A directory of your own on the PATH for good, which startup files bash runs
for login and non-login shells, and the history shortcuts.

## Before you start

The lab creates user `alex` (password `Lab-Pass-1`, shell bash). Do the
tasks as `alex`: `sudo -iu alex` or `su - alex`. On the RHEL family alex's
login startup file is `~/.bash_profile`; on Ubuntu it's `~/.profile`.

## Tasks

1. Create `~/bin/hi`, a script that prints `hi from` and its own name
   (`echo "hi from $0"`), and make it executable. Add `$HOME/bin` to the
   front of `PATH` in alex's login startup file, so that `hi` works in
   every new login shell.
2. Add the line `echo bashrc ran` to `~/.bashrc` and `echo profile ran` to
   the login startup file. Start `bash` (non-login) and `bash -l` (login)
   and see which lines each one prints. Leave the lines in place until
   you've run `le-lab check`, then remove them.
3. Practice history: run `ls /etc/ssh`, then `cd !$`, then `!!`, then
   press Ctrl+r and type `ls` to find the first command. Not graded.

## Hints

- `mkdir -p ~/bin`, `printf '#!/bin/bash\necho "hi from $0"\n' > ~/bin/hi`,
  `chmod +x`.
- `echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bash_profile` (or
  `~/.profile`), then `source` it; `which hi`.
- bash runs only the first of `~/.bash_profile`, `~/.bash_login` and
  `~/.profile` that it finds for a login shell.
