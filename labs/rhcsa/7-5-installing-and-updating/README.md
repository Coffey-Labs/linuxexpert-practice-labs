# RHCSA 7.5: Installing and updating software

Installing a package from a file with its dependencies, and applying all
available updates. (Registering a RHEL system needs a Red Hat subscription,
so it isn't part of this lab.)

## Before you start

The lab needs the VM's repositories to work. It makes sure `mariadb` isn't
installed, and that there's at least one update to apply: if the system is
fully up to date, it installs an older version of a small package
(such as `tzdata`).

## Tasks

1. Download the `mariadb` package with `dnf download`, try to install it
   with `rpm -i`, then install it from the file with its dependencies.
2. Apply all available updates and show what changed.

## Hints

- `dnf download mariadb` saves the `.rpm` in the current directory;
  `rpm -i` reports "Failed dependencies"; `dnf install ./FILE.rpm`;
  `rpm -q mariadb`, `dnf history info last`.
- `dnf check-update` (exit status `100` means updates are waiting, `0`
  none), `dnf upgrade`, `dnf history list`, `dnf history info`.
