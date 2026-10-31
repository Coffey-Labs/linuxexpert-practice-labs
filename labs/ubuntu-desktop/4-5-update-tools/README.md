# Ubuntu Desktop 4.5: Update tools

Widening what unattended-upgrades installs, purging a package so that
nothing of it is left, and asking aptitude why a library is installed.

## Before you start

The lab makes sure `nano` is installed, and adds a comment line to its
configuration file `/etc/nanorc` (a stand-in for a change you once made).
It saves `/etc/apt/apt.conf.d/50unattended-upgrades` so reset can put it
back. `aptitude` isn't installed. Write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Make unattended-upgrades also install updates from `noble-updates`,
   and check what it would install now.
2. Remove `nano` so that nothing of it is left, then install it again.
3. Install aptitude and find out which installed package depends on
   `libnl-3-200`. Write that package's name to `/root/lab-answers/3`.

## Hints

- The `Allowed-Origins` list in
  `/etc/apt/apt.conf.d/50unattended-upgrades`; `sudo unattended-upgrade
  --dry-run --debug | grep 'Allowed origins'` should include
  `a=noble-updates`.
- `apt remove` keeps configuration files; `dpkg -l nano` then shows `rc`.
  `apt purge` takes them too, so `/etc/nanorc` is gone until you install
  nano again.
- `aptitude why libnl-3-200`: the line starting with `i` that names
  `libnl-3-200` gives the package that depends on it.
