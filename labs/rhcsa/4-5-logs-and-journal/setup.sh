for f in /var/log/messages /var/log/secure; do
	[ -f "$f" ] || refuse "$f doesn't exist; is rsyslog installed and running?"
done
[ -d /var/log/journal ] && state_set had-journal-dir 1
ls /etc/systemd/journald.conf.d >"$LAB_STATE/journald-d" 2>/dev/null || true
[ -f /etc/systemd/journald.conf ] && cp -a /etc/systemd/journald.conf "$LAB_STATE/journald.conf"
rm -f /root/ssh-errors.txt
# Start from a journal kept in memory only.
mkdir -p /etc/systemd/journald.conf.d
printf '# Practice lab: keep the journal in memory only.\n[Journal]\nStorage=volatile\n' >/etc/systemd/journald.conf.d/00-le-lab.conf
systemctl restart systemd-journald
# rsyslog reads the journal; restart it so it follows the new one.
systemctl restart rsyslog
sleep 3
state_set boot-id "$(cat /proc/sys/kernel/random/boot_id)"
state_set since "$(date +%s)"
# Markers: tasks 3 and 4 look for messages after them.
token=le-lab-$(date +%s)-$RANDOM
state_set token "$token"
# Written straight into the files, so they can't be lost on the way.
for f in /var/log/messages /var/log/secure; do
	printf '%s %s le-lab: lab started %s\n' "$(date '+%b %e %T')" "$(hostname -s)" "$token" >>"$f"
done
