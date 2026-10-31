# Ubuntu Desktop 4.2: Debs and snaps

Telling a deb from a snap, replacing a deb with the snap of the same
program while keeping its settings, and getting a removed snap's data
back from its snapshot.

## Before you start

The lab changes nothing, but checks that the `htop` snap isn't installed.
Reset puts the `htop` deb back if you had it (on Ubuntu Server, removing
it also removes the `ubuntu-server` metapackage; reset puts that back
too). The VM needs to reach the snap store. Write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Find out whether Firefox on this machine is a deb or a snap. Write
   `deb`, `snap` or `none` (if it isn't installed, as on a server) to
   `/root/lab-answers/1`.
2. Install the htop deb, give it a setting (in htop, F2 Setup, Display
   options, turn on Tree view, then quit with F10), then replace it with
   the snap, keeping the setting.
3. Remove the htop snap and get its data back.

## Hints

- `dpkg -l firefox` shows the transitional `1snap1` version, a real
  version, or nothing; `snap list firefox`.
- The deb keeps its settings in `~/.config/htop/htoprc`. A snap sees its
  own home folder, `~/snap/htop/current/`, which exists once you've run
  the snap. Copy the file to `~/snap/htop/current/.config/htop/`.
- `snap remove htop` saves a snapshot of its data; `snap saved`, `snap
  install htop`, `snap restore SET`. Then `ls ~/snap/htop/*/.config/htop/`
  shows `htoprc` again.
