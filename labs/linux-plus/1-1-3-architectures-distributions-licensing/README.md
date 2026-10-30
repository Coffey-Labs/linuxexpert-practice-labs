# Linux+ 1.1.3: Architectures, distributions and licenses

Finding the machine architecture and the distribution family, a package's
license, and a package that isn't tied to one architecture.

## Before you start

The lab sets nothing up. Each task asks for a finding: write it to the file
in `/root/lab-answers/` that the task names.

## Tasks

1. Write the machine architecture on the first line of
   `/root/lab-answers/1`, and the distribution family this system says it
   belongs to (one of the words in `ID_LIKE`, such as `rhel` or `debian`) on
   the second.
2. Find the license of the `bash` package and write it to
   `/root/lab-answers/2`.
3. Find a package that isn't architecture-specific and write its name to
   `/root/lab-answers/3`.

## Hints

- `uname -m`; `grep -E '^(ID|ID_LIKE|VERSION_ID)=' /etc/os-release`.
- `rpm -q --qf '%{NAME}: %{LICENSE}\n' bash` on the RHEL family;
  `/usr/share/doc/bash/copyright` on Debian and Ubuntu.
- `rpm -qa --qf '%{ARCH} %{NAME}\n' | grep ^noarch`;
  `dpkg -l | awk '$4=="all"{print $2}'`.
