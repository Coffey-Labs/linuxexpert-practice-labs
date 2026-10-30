# LFCS 1.4: Software packages

Finding which package has a command, adding a third-party repository,
verifying installed files, and holding a package at its version.

## Before you start

The VM needs internet access. The lab makes sure `dig` isn't installed, and
changes one character in a configuration file of the `openssh-server`
package (a comment, so sshd keeps working). On Ubuntu, removing `dig` also
removes the `ubuntu-standard` metapackage; reset puts both back.

## Tasks

1. Find which package provides the `dig` command, install it, and list the
   package's files. Write the package's name to `/root/lab-answers/1`.
2. Add a third-party repository with its signing key (Docker's or another
   vendor's published instructions are good practice), install a package
   from it, then remove the repository so it's no longer used. Write the
   package's name to `/root/lab-answers/2`.
3. Find the changed file with the package manager, write its full path to
   `/root/lab-answers/3`, and restore the packaged file.
   `rpm -V openssh-server` or `dpkg --verify openssh-server` lists the file
   until it's restored.
4. Stop the package `curl` from being upgraded.

## Hints

- `dnf provides`, `rpm -qf`, `rpm -ql`; `apt-file search`, `dpkg -S`,
  `dpkg -L`.
- A `.repo` file in `/etc/yum.repos.d/`, or a `.sources` file in
  `/etc/apt/sources.list.d/` with a key in `/etc/apt/keyrings/`;
  `dnf repolist`, `apt-cache policy`.
- `rpm -V`, `dpkg --verify`; delete the file, then `dnf reinstall` or
  `apt install --reinstall -o Dpkg::Options::=--force-confmiss`.
- `dnf versionlock` (from `python3-dnf-plugin-versionlock`), `apt-mark hold`.
