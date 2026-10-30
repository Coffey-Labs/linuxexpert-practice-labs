# Linux+ 2.4.1: Package managers

Asking which package owns a file, installing and removing with a history
to show for it, and holding a package back from upgrades.

## Before you start

The lab notes where your package history stands, so it can see what you
install and remove from now on. It needs `tree` not to be installed.
Write answers to the files in `/root/lab-answers/`.

## Tasks

1. Find out which package owns `/usr/bin/ssh`, and write the package name
   (without version) to `/root/lab-answers/1`. Look at its description and
   file list too.
2. Install `tree`, check the package history, and then remove it again (on
   RHEL relatives, by undoing the last transaction).
3. Hold `bash` so that upgrades skip it, and check that an upgrade leaves it
   alone. Leave the hold in place for grading.

## Hints

- `rpm -qf`, `rpm -qi`, `rpm -ql`; `dpkg -S`, `dpkg -s`, `dpkg -L`.
- `dnf history`, `dnf history undo last`; `apt install`, `apt remove`,
  `/var/log/apt/history.log`.
- `dnf versionlock add` (package `python3-dnf-plugin-versionlock`),
  `dnf upgrade --assumeno`; `apt-mark hold`, `apt-mark showhold`.
- The chapter's step 4 (the signing keys you trust) isn't graded.
