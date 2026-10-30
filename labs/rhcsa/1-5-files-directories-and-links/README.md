# RHCSA 1.5: Files, directories and links

Creating a directory tree in one command, copying with everything kept,
hard and symbolic links, and editing a file with vi.

## Before you start

The lab saves `/etc/motd` and puts it back on reset. It removes
`/root/skel-backup`, `/root/hosts-hard` and `/root/hosts-soft` if they
exist.

## Tasks

1. Create the directories `/data/web/html` and `/data/web/logs` in one
   command.
2. Copy `/etc/skel` to `/root/skel-backup`, keeping permissions, ownership
   and timestamps, including the hidden files.
3. Create a hard link `/root/hosts-hard` to `/etc/hosts` and a symbolic
   link `/root/hosts-soft` to it.
4. Using vi, add the line `Authorized users only` at the end of
   `/etc/motd`, then quit.

## Hints

- `mkdir -p` and brace expansion: `{html,logs}`.
- `cp -a`; `ls -la` shows the dot files and dates.
- `ln`, `ln -s`; `ls -li` shows inode numbers.
- `G` goes to the last line, `o` opens a line below it, Esc, then `:wq`.
