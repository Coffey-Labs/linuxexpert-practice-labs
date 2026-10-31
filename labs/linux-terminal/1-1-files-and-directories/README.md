# Using Linux Terminal 1.1: Files and directories

Making a directory tree in one command, copying with hidden files and
dates kept, hard and symbolic links, and removing directories.

## Before you start

The lab creates user `student` (password `Lab-Pass-1`). Work as `student`
(`sudo -iu student`), so `~` is `/home/student`. The lab only checks that
`~/lab` doesn't exist yet; `le-lab reset` removes it.

## Tasks

1. Create `~/lab/app/config`, `~/lab/app/logs` and `~/lab/app/data` in one
   command, and copy `/etc/skel` to `~/lab/skel`, keeping its hidden files
   and timestamps.
2. In `~/lab`, create `notes.txt` containing the word `hello`, a hard link
   `notes.hard` and a symbolic link `notes.link` to it. Then rename
   `notes.txt` to `notes.old`, and see what `cat` makes of each link.
3. Remove `~/lab/app/logs` with `rmdir`. Put a file in `~/lab/app/data`,
   try `rmdir` on it, then remove that directory too. Only `config` is left
   in `~/lab/app`.

## Hints

- `mkdir -p` with a brace list: `{config,logs,data}`.
- `cp -a`; compare `ls -la ~/lab/skel` with `ls -la /etc/skel`.
- `ln`, `ln -s`, `mv`; `ls -li` shows inode numbers and `stat -c %h` the
  link count.
- `rmdir` only removes empty directories: "Directory not empty". `rm -r`.
