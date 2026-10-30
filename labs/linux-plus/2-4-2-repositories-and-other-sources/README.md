# Linux+ 2.4.2: Repositories and other sources

An extra repository, alternatives, a Python virtual environment, and
building a small program from source.

## Before you start

Work as root, so `~` is `/root`. The VM needs internet access. The lab
sets the `editor` alternative to automatic mode (on Debian and Ubuntu) and
checks that `~/venv` and `~/src` don't exist yet. Leave your work in
place for grading.

## Tasks

1. RHEL relatives: add the EPEL repository, enable the CRB repository, and
   install `htop` from EPEL.
2. Debian and Ubuntu: look at the APT sources and the alternatives for
   `editor`, then choose an editor yourself with `update-alternatives
   --config editor`.
3. See what `pip3 install` does outside a virtual environment, then create
   the virtual environment `~/venv` and install `requests` into it.
4. In `~/src`, write `hi.c` (a program that prints `built`) and a
   `Makefile` with a `hi` target that compiles it and an `install` target
   that copies it to `/usr/local/bin/hi`. Build it, install it, and run
   `hi`.

## Hints

- `dnf repolist --all`, `dnf install epel-release`, `dnf config-manager
  --set-enabled crb`, `dnf list --installed htop` (the repo column).
- `cat /etc/apt/sources.list.d/*.sources`, `update-alternatives
  --display editor`.
- Ubuntu needs `python3-venv` (and `python3-pip`); `python3 -m venv`,
  `~/venv/bin/pip install`, `~/venv/bin/pip list`.
- `gcc` and `make` (`build-essential` on Ubuntu); Makefile recipe lines
  start with a tab.
