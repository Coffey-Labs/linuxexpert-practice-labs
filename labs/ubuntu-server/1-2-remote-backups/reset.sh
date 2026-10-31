systemctl disable --now --quiet le-lab-peer-sshd.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-peer-sshd.service
# Units and scripts made since the lab started: the backup's.
for f in /etc/systemd/system/*.timer /etc/systemd/system/*.service; do
	[ -f "$f" ] || continue
	n=${f##*/}
	case $n in le-lab-*) continue ;; esac
	grep -qxF "$n" "$LAB_STATE/units-before" 2>/dev/null && continue
	systemctl disable --now --quiet "$n" 2>/dev/null
	rm -rf "$f" "$f.d"
done
systemctl daemon-reload
for f in /usr/local/sbin/* /usr/local/bin/*; do
	[ -f "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/local-before" 2>/dev/null && continue
	grep -q rsync "$f" 2>/dev/null && rm -f "$f"
done
rm -f /var/lib/systemd/timers/stamp-*backup*
rm -f /root/.ssh/backup_key /root/.ssh/backup_key.pub
[ -f /root/.ssh/known_hosts ] && ssh-keygen -R 10.99.0.2 >/dev/null 2>&1 && ssh-keygen -R peer >/dev/null 2>&1
rm -f /root/.ssh/known_hosts.old
pkill -KILL -u bkp 2>/dev/null
userdel -r bkp 2>/dev/null
rm -rf /srv/backups
if [ -f "$LAB_STATE/motd.orig" ]; then cp -a "$LAB_STATE/motd.orig" /etc/motd; else rm -f /etc/motd; fi
true
