# Using Linux Terminal 1.2: Searching, comparing and changing files

grep and regular expressions, find with errors thrown away, sed with a
backup, and diff.

## Before you start

The lab creates user `student` (password `Lab-Pass-1`). Work as `student`
(`sudo -iu student`), so `~` is `/home/student`. The lab removes the files
the tasks create if they exist, and `le-lab reset` removes them again.

## Tasks

1. Write the names of all users whose shell is `/bin/bash` to
   `~/bash-users.txt`, one per line, and nothing else.
2. As `student`, find every regular file under `/etc` bigger than 100 KiB
   and save the list in `~/big-etc.txt`, with any permission errors thrown
   away: none on the screen and none in the file.
3. Copy `/etc/ssh/sshd_config` to `~/sshd.copy`, then use `sed` to change
   `#Port 22` to `Port 2222` in the copy, keeping a `.bak` of it. `diff
   ~/sshd.copy.bak ~/sshd.copy` shows just that one line changed.

## Hints

- `grep '/bin/bash$' /etc/passwd`, then `cut -d: -f1`; compare `wc -l`
  with `grep -c`.
- `find /etc -type f -size +100k`, and `2>/dev/null` for the errors.
- `sed -i.bak 's/^#Port 22$/Port 2222/'`; diff shows a `c` change.
