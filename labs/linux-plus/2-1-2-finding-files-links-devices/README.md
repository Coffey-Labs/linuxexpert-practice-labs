# Linux+ 2.1.2: Finding files, links and device files

Finding files by size and permission, the locate database, hard and
symbolic links, and finding which process holds a file open.

## Before you start

Work as root. The lab installs `plocate` and `lsof`, leaves a large file
and an extra set-user-ID program somewhere on the root filesystem, and
starts a process that keeps `/tmp/held.txt` open. Write answers to the
files in `/root/lab-answers/`. Don't run the chapter's final clean-up
(`rm -f ... /tmp/h.txt /tmp/s.txt ~/findme-*.txt`): the lab grades those
files, and `le-lab reset` removes them.

## Tasks

1. Find every regular file over 50 MiB and every set-user-ID file on the
   root filesystem (don't cross into other filesystems). Save their full
   paths, one per line, in `/root/lab-answers/1` (`ls -l` style lines are
   fine too).
2. Create a file `~/findme-<something>.txt`, then make `locate findme-`
   find it.
3. In `/tmp`, create `t.txt` containing `hi`, a hard link `h.txt` to it and
   a symbolic link `s.txt` to it. Then delete `t.txt`, and see which of the
   two links still works.
4. Find the process that holds `/tmp/held.txt` open, and write its PID to
   `/root/lab-answers/4`.

## Hints

- `find / -xdev -type f -size +50M`, `find / -xdev -perm -4000 -type f`,
  `2>/dev/null`.
- `locate` only knows what the last `updatedb` saw.
- `ln`, `ln -s`, `ls -li`.
- `lsof /tmp/held.txt`, or `fuser`.
