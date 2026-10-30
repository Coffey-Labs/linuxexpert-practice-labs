# Linux+ 1.5.2: Redirection and pipes

Output and errors in separate files, here documents with and without
expansion, `tee`, and file names with spaces through `xargs`.

## Before you start

The lab clears away the files the tasks create, if they're there. Several
are in `/tmp`, which Ubuntu empties at boot, so do the tasks without a
reboot and run `le-lab check` before you clean up.

## Tasks

1. Make a directory `/tmp/redir` and work in it. Run
   `ls /etc /nonexistent` four ways: output to `out.txt` and errors to
   `err.txt`; both into `all.txt`; and with `2>&1 > only-out.txt`. Watch
   where the error goes in the last one.
2. With here documents, write `user=$USER` to `/tmp/a.txt` with the
   variable expanded, and to `/tmp/b.txt` exactly as written.
3. Count the login shells in `/etc/passwd`, most common first. Then save
   `getent passwd` to `/tmp/users.txt` and count its lines in the same
   pipeline.
4. Make a directory `/tmp/x` with two files, `a b.tmp` and `c d.tmp`. See
   `find ... | xargs rm` fail on the spaces, then remove them safely with
   `find` and `xargs`. Leave `/tmp/x` itself.

## Hints

- `> out.txt 2> err.txt`, `> all.txt 2>&1`; redirections apply left to
  right.
- `<< EOF` expands variables; `<< 'EOF'` doesn't.
- `cut -d: -f7 /etc/passwd | sort | uniq -c | sort -rn`;
  `getent passwd | tee /tmp/users.txt | wc -l`.
- `find /tmp/x -name '*.tmp' -print0 | xargs -0 rm`.
