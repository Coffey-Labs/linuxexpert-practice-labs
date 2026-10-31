# Ubuntu Desktop 2.1: LTS releases and version numbers

Finding this system's release and point release, when its support ends,
and which Ubuntu releases are still supported.

## Before you start

The lab installs `distro-info` if it's missing and changes nothing else.
Write your answers to the files in `/root/lab-answers/`, one item per
line.

## Tasks

1. Find this system's release, code name and point release. Write the
   point release (such as `24.04.5`) on line 1 of `/root/lab-answers/1`
   and the code name on line 2.
2. Find the date standard support ends for this release, and for the
   latest LTS. Write them on lines 1 and 2 of `/root/lab-answers/2`, as
   `YYYY-MM-DD` (or at least the month, such as `May 2029`).
3. List every Ubuntu release still supported today, and say which of them
   are LTS releases. Write one release per line to `/root/lab-answers/3`
   as its version number, followed by `LTS` for the LTS ones (such as
   `24.04 LTS`). The development release may be left out.

## Hints

- `lsb_release -a`, `/etc/os-release`.
- The `eol` column of `/usr/share/distro-info/ubuntu.csv`;
  `hwe-support-status --verbose`; `ubuntu-distro-info --lts`.
- `ubuntu-distro-info --supported --fullname`, and `--devel` for the
  release still being developed.
