# LPIC-1 102.4: Debian package management

Installing, inspecting, removing and purging packages, finding which
package owns a file, installing a downloaded `.deb`, and reconfiguring a
package.

## Before you start

The lab makes sure `cowsay` and `hello` aren't installed, and sets the
time zone to UTC if it's Europe/Berlin already (reset puts the old one
back). Write answers to the files in `/root/lab-answers/`.

## Tasks

1. Install `cowsay` with `apt-get`, list its files with `dpkg -L`, check
   its status with `dpkg -s`, then remove it and purge it, checking
   `dpkg -l` after each step.
2. Find which package provides `/usr/bin/ls`, then try `/bin/ls` and see
   why it fails. Then use `apt-file` to find which package would provide
   the `ab` command, which you don't have yet. Write the package that owns
   `/usr/bin/ls` on line 1 of `/root/lab-answers/2`, and the package with
   `ab` on line 2.
3. Download the `hello` package with `apt-get download` in `/root`, list
   its contents with `dpkg -c`, and install it with `dpkg -i`.
4. Run `dpkg-reconfigure tzdata` and change the time zone to
   Europe/Berlin.

## Hints

- `dpkg -l cowsay` shows `ii` while it's installed. A package with
  configuration files shows `rc` after `apt-get remove` and disappears
  with `apt-get purge`; `cowsay` has none (`dpkg -s` lists no
  `Conffiles:`), so it's gone after `remove` and `purge` has nothing left
  to do.
- `dpkg -S`; `/bin` is a symlink to `usr/bin`, and the package lists the
  file only under `/usr/bin`. `apt-get install apt-file`, `apt-file
  update`, `apt-file search bin/ab`.
- `apt-get download hello`, `dpkg -c`, `dpkg -i`.
- `timedatectl`, `ls -l /etc/localtime`, `cat /etc/timezone`.
