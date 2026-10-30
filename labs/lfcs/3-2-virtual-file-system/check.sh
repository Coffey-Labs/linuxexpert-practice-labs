in_fstab() { findmnt -s -n "$1" >/dev/null || [ -e "/etc/systemd/system/$(systemd-escape -p --suffix=mount "$1")" ]; }
has_opt() { findmnt -n -o OPTIONS "$1" | tr , '\n' | grep -qx "$2"; }
# Try to run a small script from directory $1; succeeds if it ran.
runs_from() {
	local f=$1/.le-lab-check.sh rc
	printf '#!/bin/sh\nexit 0\n' >"$f" || return 1
	chmod 755 "$f"
	"$f"; rc=$?
	rm -f "$f"
	return $rc
}
same_dir() { [ "$(stat -c %d:%i "$1")" = "$(stat -c %d:%i "$2")" ]; }
# A file made in $1 shows up in $2.
shows_up() {
	local n=.le-lab-check-$$ rc=1
	touch "$1/$n" && [ -e "$2/$n" ] && rc=0
	rm -f "$1/$n"
	return $rc
}

task 1 "/data: read-write, noexec, at every boot"
need "/data is mounted from /dev/loop40" '[ "$(findmnt -n -o SOURCE /data)" = /dev/loop40 ]'
need "/data is mounted read-write" has_opt /data rw
need "/data is mounted with noexec" has_opt /data noexec
need "a script copied to /data won't run" '! runs_from /data'
need "/data is in /etc/fstab with noexec" 'findmnt -s -n -o OPTIONS /data | tr , "\n" | grep -qx noexec'
need "/etc/fstab doesn't mount /data read-only" '! findmnt -s -n -o OPTIONS /data | tr , "\n" | grep -qx ro'

task 2 "/srv/shared also at /home/alice/shared at boot"
need "/home/alice/shared is a mount point" findmnt -n /home/alice/shared
need "/home/alice/shared shows /srv/shared" same_dir /srv/shared /home/alice/shared
need "a file made in /srv/shared shows up in /home/alice/shared" shows_up /srv/shared /home/alice/shared
need "the bind mount is set up at boot (/etc/fstab)" in_fstab /home/alice/shared

task 3 "256 MiB tmpfs at /scratch, mode 1777, at boot"
need "/scratch is a tmpfs" '[ "$(findmnt -n -o FSTYPE /scratch)" = tmpfs ]'
need "/scratch is 256 MiB" '[ "$(df -BM --output=size /scratch | tail -n1 | tr -dc 0-9)" = 256 ]'
need "/scratch is drwxrwxrwt (mode 1777)" '[ "$(stat -c %a /scratch)" = 1777 ]'
need "/scratch is mounted at boot (/etc/fstab)" in_fstab /scratch

task 4 "/tmp mounted noexec and nosuid at boot"
need "/tmp is mounted with noexec" has_opt /tmp noexec
need "/tmp is mounted with nosuid" has_opt /tmp nosuid
need "/tmp is set up that way at boot (/etc/fstab or tmp.mount)" 'findmnt -s -n -o OPTIONS /tmp | grep -qw noexec || grep -rqsw noexec /etc/systemd/system/tmp.mount /etc/systemd/system/tmp.mount.d'
