# RHCSA 9.3: Local groups and membership

Creating a group with members, changing its members, name and GID, and why
a user's own group can't be deleted.

## Before you start

The lab creates users `alice` and `bob` (password `Lab-Pass-1`). `alice`
is already in a supplementary group, `projects`, and `bob` in `support`;
they must stay there. Task 2 changes what task 1 made, so the lab runs a
small service, `le-lab-watch`, that notes the group every second for the
check. Do the tasks in order.

## Tasks

1. Create a group `sales` with GID 3000, and add `alice` and `bob` to it
   as a supplementary group without changing their other groups.
2. Remove `bob` from `sales`, and rename the group to `market` with GID
   3001.
3. Try to delete `alice`'s private group (`alice`) while she exists, and
   write the error message `groupdel` prints to `/root/lab-answers/3`.

## Hints

- `groupadd -g`, `usermod -aG` (without `-a`, `-G` replaces the list) or
  `gpasswd -a`; `getent group sales`, `id alice`.
- `gpasswd -d`, `groupmod -n -g`.
- `groupdel alice 2>/root/lab-answers/3`.
