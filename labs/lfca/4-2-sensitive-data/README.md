# LFCA 4.2: Sensitive data

A secret committed to Git and taken out of its history again, and a file
encrypted before its original is shredded.

## Before you start

Work as root (`sudo -i`). The lab installs Git if it's missing and creates
a test repository, `/root/leaky`, in which someone committed a file
`config.env` with a fake API key, and later commits on top. It also
creates `/root/customers.csv`. It notes which packages were installed, and
reset puts that back. The VM needs internet access to install the tools.

## Tasks

1. Find the key in `/root/leaky` with `gitleaks detect` (from Ubuntu's
   packages; on the RHEL family, the upstream release) or with
   `git log -p | grep`. Then remove `config.env` from the whole history
   with `git filter-repo --force --path config.env --invert-paths`, keeping
   the other files and commits. Note why the key would still need to be
   rotated.
2. Encrypt `/root/customers.csv` with `gpg -c`, and delete the original
   with `shred -u`. Then read `man shred` and note why it isn't reliable on
   SSDs or on copy-on-write filesystems such as Btrfs.

## Hints

- `cd /root/leaky`, `git log --oneline --stat`, `git log -p | grep -i key`.
- `apt install gitleaks git-filter-repo` on Ubuntu. On the RHEL family,
  `git-filter-repo` is in EPEL (`dnf install epel-release`, then
  `dnf install git-filter-repo`).
- After filter-repo, `git log --all --oneline -- config.env` shows nothing.
- `gpg -c customers.csv` asks for the passphrase twice; `ls` after
  `shred -u`.
