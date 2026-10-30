storage=$(systemd-analyze cat-config systemd/journald.conf 2>/dev/null | sed -n 's/^[[:space:]]*Storage=//p' | tail -n1)
[ "$storage" = persistent ] &&
	refuse "journald is set to Storage=persistent already; task 3 does that. Remove the setting first."
pkg_installed rsyslog && state_set had-rsyslog 1
state_set since "$(date '+%Y-%m-%d %H:%M:%S')"
# journald's and rsyslog's configuration, for reset.
[ -f /etc/systemd/journald.conf ] && cp -a /etc/systemd/journald.conf "$LAB_STATE/journald.conf"
ls /etc/systemd/journald.conf.d >"$LAB_STATE/journald-d" 2>/dev/null || true
[ -f /etc/rsyslog.conf ] && cp -a /etc/rsyslog.conf "$LAB_STATE/rsyslog.conf"
ls /etc/rsyslog.d >"$LAB_STATE/rsyslog-d" 2>/dev/null || true
# A journal kept only in /run.
if [ -d /var/log/journal ]; then
	[ -e /var/log/journal.le-lab ] && refuse "/var/log/journal.le-lab exists already; move it out of the way first"
	journalctl --relinquish-var
	mv /var/log/journal /var/log/journal.le-lab
	state_set moved-journal 1
fi
rm -rf /var/log/lrtest /etc/logrotate.d/lrtest
true
