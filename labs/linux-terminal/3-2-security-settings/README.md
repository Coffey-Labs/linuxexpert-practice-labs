# Using Linux Terminal 3.2: System-wide and per-user security settings

A process limit for one user, a message for every login shell, and a
stricter umask for one user.

## Before you start

The lab creates users `alice` and `student` (password `Lab-Pass-1`).
Work as root (`sudo -i`) for tasks 1 and 2, and as `student` (`sudo -iu
student`) for task 3. The lab saves `/etc/profile`, `/etc/bash.bashrc` and
the limits files, and puts them back on reset; it also removes the files
you add to `/etc/profile.d` and `/etc/security/limits.d`.

## Tasks

1. Limit the user `alice` to 50 processes, as both soft and hard limit, in
   a file of its own. `su - alice -c 'ulimit -u; ulimit -Hu'` prints `50`
   twice, and other users' limits are unchanged.
2. Make every login shell print `Authorized use only` before the prompt,
   without editing `/etc/profile`. `su - alice -c true` prints the message.
3. Give `student` a umask of 077 in every interactive shell: in a new
   shell, `umask` prints `0077`, and `touch ~/x; ls -l ~/x` shows
   `-rw-------`. Other users keep their umask.

## Hints

- A file in `/etc/security/limits.d/` with `alice`, `-` (or a `soft` and a
  `hard` line), `nproc` and `50`. Limits apply at the next login.
- A `.sh` file in `/etc/profile.d/` with an `echo`.
- `~/.bashrc` runs in every interactive bash (and Ubuntu's `~/.profile`
  runs it for login shells); `bash` starts a new one to test.
