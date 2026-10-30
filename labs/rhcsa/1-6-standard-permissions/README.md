# RHCSA 1.6: Standard permissions

Owners and modes on a file, a directory only its group can use, fixing a
whole tree in one command, and finding the directory that blocks access.

## Before you start

The lab creates users `alice` and `bob` (neither is in `wheel`), a tree
`/srv/project` whose files and directories have a mix of modes, and
`/opt/app/conf/app.conf`, mode 644, that alice can't read. Write the
finding of task 4 to `/root/lab-answers/4`.

## Tasks

1. Create `/srv/reports/q3.txt`, owned by `alice` and the group `wheel`,
   readable and writable by alice, readable by the group, and with no
   access for anyone else.
2. Make the directory `/srv/reports` usable by its group (list, enter,
   create files) but closed to others.
3. Make every directory under `/srv/project` mode 755 and every file 644 in
   one `chmod` command.
4. Find out why alice can't read `/opt/app/conf/app.conf` although the
   file is mode 644. Write the full path of the directory that blocks her
   to `/root/lab-answers/4`, then fix it so she can read the file.

## Hints

- `chown alice:wheel`, `chmod 640` or `chmod u=rw,g=r,o=`.
- A directory needs `x` to be entered and `r` to be listed: `770`.
  `su - bob -c 'ls /srv/reports'` should fail.
- `chmod -R u=rwX,go=rX`: capital `X` sets execute only on directories
  (and files that already have it, so check the files too).
- `namei -l` shows the permissions of every directory on the path.
