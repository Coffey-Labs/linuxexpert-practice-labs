state_set start "$(date +%s)"
# The journal in memory only: move a saved journal aside.
if [ -d /var/log/journal ]; then
	journalctl --relinquish-var
	mv /var/log/journal "$LAB_STATE/journal.saved"
	journalctl --flush
fi
# The application's log.
if [ ! -d /var/log/labapp ]; then
	mkdir -p /var/log/labapp
	for i in 1 2 3; do echo "$(date '+%F %T') labapp: request $i served"; done >/var/log/labapp/app.log
fi
rm -f /etc/logrotate.d/labapp
