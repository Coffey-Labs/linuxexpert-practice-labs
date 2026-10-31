# Using Linux Terminal 3.6: Ownership and permissions

A shared group directory with setgid and the sticky bit, private files in
octal, and finding setuid programs.

## Before you start

Work as root (`sudo -i`) for tasks 1 and 3, and as `student` (`sudo -iu
student`) for task 2. Write answers to the files in `/root/lab-answers/`.
The lab creates users `ana`, `ben` and `student` (password `Lab-Pass-1`),
and checks that `/srv/finance` and group `finance` don't exist yet;
`le-lab reset` removes them.

## Tasks

1. Create `/srv/finance` owned by root and the group `finance` (create the
   group, with `ana` and `ben` as its members), where members can create
   and edit files, new files belong to `finance`, members can't delete each
   other's files, and others have no access. `ls -ld /srv/finance` shows
   `drwxrws--T root finance` (mode 3770).
2. As `student`, make `~/private` a directory only you can enter, and
   `~/private/notes.txt` a file only you can read and write, using octal.
3. List every setuid file on the root filesystem, find the one that lets
   users change their own password, and write its full path to
   `/root/lab-answers/3`.

## Hints

- `groupadd`, `usermod -aG` (or `gpasswd -a`); `chown root:finance`,
  `chmod 3770`. Test with `su - ana -c 'touch /srv/finance/a'` and `su -
  ben -c 'rm /srv/finance/a'`.
- `chmod 700`, `chmod 600`; `stat -c '%a %n'`.
- `find / -xdev -perm -4000 -type f 2>/dev/null`; `ls -l` shows the `s`.
