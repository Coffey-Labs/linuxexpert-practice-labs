K=/root/.ssh/backup_key
B=/srv/backups/s1-etc
SSH="ssh -i $K -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"
# What a dry run would still send: changed files, not just directory times.
pending() {
	timeout 60 rsync -ani --delete -M--fake-super -e "$SSH" /etc/ bkp@10.99.0.2:$B/ 2>/dev/null |
		grep -Ev '^\.d\.\.t\.+ ' >"$LAB_STATE/pending"
	[ "${PIPESTATUS[0]}" -eq 0 ]
}
# The backup timers: timers whose service runs rsync to the peer.
timers() {
	local t s x f
	for t in $(systemctl list-unit-files --type=timer --no-legend | awk '{ print $1 }'); do
		s=$(systemctl show -p Unit --value "$t")
		x=$(systemctl show -p ExecStart --value "$s" 2>/dev/null | sed -n 's/.*path=\([^ ;]*\).*/\1/p')
		{ systemctl cat "$s" 2>/dev/null; [ -f "$x" ] && cat "$x"; } | grep -q 'rsync' || continue
		echo "$t"
	done
}
t1() { timers | head -n1; }

task 1 "/etc backed up to the peer as bkp with rsync and its own key"
need "user bkp exists and isn't root" 'id bkp && [ "$(id -u bkp)" != 0 ]'
need "/root/.ssh/backup_key is a key without a passphrase" 'ssh-keygen -y -P "" -f $K'
need "bkp's authorized_keys holds the backup key" 'h=$(getent passwd bkp | cut -d: -f6); grep -qF "$(awk "{ print \$2 }" $K.pub)" $h/.ssh/authorized_keys'
need "root logs in to the peer as bkp with the key" 'timeout 15 $SSH bkp@10.99.0.2 true </dev/null'
need "/srv/backups/s1-etc holds /etc's files" 'test -f $B/hostname && test -f $B/passwd && test -d $B/ssh'
need "the copies belong to bkp, not root" '[ "$(stat -c %U $B/passwd)" = bkp ] && [ "$(stat -c %U $B/shadow)" = bkp ]'
need "a dry run with -M--fake-super has nothing to send" 'pending && [ "$(wc -l <"$LAB_STATE/pending")" -le 2 ]'

task 2 "A timer runs the backup daily at 01:15 and catches up"
need "a timer starts a service that runs rsync" '[ -n "$(t1)" ]'
need "the timer is enabled and active" 'enabled "$(t1)" && active "$(t1)"'
need "it runs daily at 01:15" 'systemctl show -p TimersCalendar --value "$(t1)" | grep -q "OnCalendar=\*-\*-\* 01:15:00"'
need "it catches up after downtime (Persistent=true)" '[ "$(systemctl show -p Persistent --value "$(t1)")" = yes ]'
need "the service has run and finished" 'journalctl -u "$(systemctl show -p Unit --value "$(t1)")" -o cat 2>/dev/null | grep -q "^Finished"'

task 3 "/etc/motd deleted and restored with its owner and mode"
need "/etc/motd exists" test -f /etc/motd
need "it's the file the lab wrote" '[ "$(md5sum </etc/motd)" = "$(state_get motd-sum)" ]'
need "it was deleted and restored (it's a new file)" '[ "$(stat -c "%i %w" /etc/motd)" != "$(state_get motd-id)" ]'
need "it has its original owner, group and mode (root adm 640)" '[ "$(stat -c "%U %G %a" /etc/motd)" = "root adm 640" ]'
