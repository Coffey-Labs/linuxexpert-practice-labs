# LPIC-1 104.6: Hard and symbolic links

Hard links and symlinks side by side, the limits of hard links, directory
link counts, switching a `current` symlink, and following a chain of
links.

## Before you start

The lab creates an empty `/root/links/`. Work as root (`sudo -i`) and in
that directory, and write answers to the files in `/root/lab-answers/`.

## Tasks

1. Create `original.txt` with some text, make a hard link `hard.txt` and a
   symlink `soft.txt` to it, and look at all three with `ls -li`. Delete
   the original, then `cat` both links.
2. Try to hard-link a file onto another filesystem (`df` shows which
   directories are on separate ones), and to hard-link a directory. Write
   both error messages to `/root/lab-answers/2`.
3. Make a directory `parent`, check its link count, add two
   subdirectories, and check again. Write the first count on line 1 of
   `/root/lab-answers/3` and the second on line 2.
4. Set up `releases/1.0`, `releases/1.1` and a `current` symlink in
   `releases/` pointing to `1.0`. Switch `current` to `1.1` with `ln -sf`,
   and then with `ln -sfn`, and look at what each did.
5. On Debian or Ubuntu, follow `/usr/bin/editor` to the real program with
   `readlink -f`, and with `ls -l` one link at a time. Write every name in
   the chain, from `/usr/bin/editor` to the real program, one per line, to
   `/root/lab-answers/5`.

## Hints

- `ln`, `ln -s`, `ls -li`; a symlink stores a name, a hard link is another
  name for the same inode.
- `/tmp` is on the root filesystem on many systems; `/dev/shm` and `/run`
  are tmpfs. `ln FILE /dev/shm/`; `ln DIR NEWNAME`.
- `ls -ld parent` (the second column), `stat -c %h parent`.
- Without `-n`, `ln -sf 1.1 current` follows `current` into `1.0` and
  makes the link there.
- `readlink -f`, `ls -l /usr/bin/editor`, then `ls -l` on what it points
  to.
