# Ubuntu Server 1.2: Automated remote backups

A backup of `/etc` to another machine with rsync over SSH, as a user other
than root, a nightly systemd timer, and a restore that keeps owners.

## Before you start

The peer, at `10.99.0.2` (name `peer`), is the backup server, s2. It runs
its own sshd, and shares this VM's users and files: an account you create
here exists there too, and the peer's `/srv/backups` is this VM's. Reach it
with `ssh peer`; get a shell in its network with `sudo ip netns exec lepeer
bash`.

The lab writes an `/etc/motd` for task 3; look at its owner and mode with
`ls -l /etc/motd` before you start.

## Tasks

1. As root, back up `/etc` to `/srv/backups/s1-etc/` on the peer as a user
   `bkp` (not root), using rsync over SSH with a dedicated key,
   `/root/.ssh/backup_key`. `sudo rsync -avn --delete -M--fake-super -e
   "ssh -i /root/.ssh/backup_key" /etc/ bkp@peer:/srv/backups/s1-etc/`
   lists no files to send and ends with `(DRY RUN)`.
2. Run that backup every day at 1:15 am with a systemd timer that catches
   up after downtime. `systemctl list-timers` shows your timer with the
   next run at 01:15 (plus any random delay); `sudo systemctl start` of the
   service ends with "Finished" in its journal.
3. Delete `/etc/motd`, then restore it from the peer. After the restore,
   `ls -l /etc/motd` shows the file with its original owner and mode.

## Hints

- `ssh-keygen -N "" -f /root/.ssh/backup_key`; `useradd -m`, `install -d
  -o bkp -g bkp`, `~bkp/.ssh/authorized_keys`. Connect once by hand with
  `-o StrictHostKeyChecking=accept-new` so the host key is known.
- `rsync -a --delete -M--fake-super -e "ssh -i KEY -o BatchMode=yes"`: the
  trailing slash on `/etc/` matters.
- A `Type=oneshot` service and a `.timer` with `OnCalendar=`,
  `Persistent=true`; enable the timer. `systemd-analyze calendar`,
  `systemctl list-timers`, `journalctl -u`.
- The same rsync the other way, with `-M--fake-super`.
