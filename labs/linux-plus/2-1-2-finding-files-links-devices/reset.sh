systemctl stop le-lab-held.service 2>/dev/null
systemctl reset-failed le-lab-held.service 2>/dev/null
rm -rf /var/lib/le-report /usr/local/sbin/le-backup-helper
rm -f /tmp/held.txt /tmp/t.txt /tmp/h.txt /tmp/s.txt /root/findme-*.txt
if [ -n "$(state_get plocate)" ]; then
	if is_rhel; then dnf -y -q remove plocate >/dev/null; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge plocate >/dev/null 2>&1; fi
	rm -rf /var/lib/plocate
fi
if [ -n "$(state_get lsof)" ]; then
	if is_rhel; then dnf -y -q remove lsof >/dev/null; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge lsof >/dev/null 2>&1; fi
fi
true
