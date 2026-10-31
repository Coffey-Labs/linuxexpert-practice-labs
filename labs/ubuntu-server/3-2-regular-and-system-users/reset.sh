# Units made since the lab started: the reportsvc service.
for f in /etc/systemd/system/*.service; do
	[ -f "$f" ] || continue
	n=${f##*/}
	case $n in le-lab-*) continue ;; esac
	grep -qxF "$n" "$LAB_STATE/units-before" 2>/dev/null && continue
	systemctl disable --now --quiet "$n" 2>/dev/null
	rm -rf "$f" "$f.d"
done
systemctl daemon-reload
pkill -KILL -u reportsvc 2>/dev/null
userdel -r reportsvc 2>/dev/null
groupdel reportsvc 2>/dev/null
rm -rf /var/lib/reportsvc
true
