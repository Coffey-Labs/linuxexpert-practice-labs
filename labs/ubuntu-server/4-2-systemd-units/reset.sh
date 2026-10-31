# The lab's service, and any service made since the lab started.
for f in /etc/systemd/system/*.service; do
	[ -e "$f" ] || [ -L "$f" ] || continue
	n=${f##*/}
	case $n in le-lab-*) continue ;; esac
	grep -qxF "$n" "$LAB_STATE/units-before" 2>/dev/null && continue
	# A mask is a link to /dev/null; unmask apport below.
	[ "$(readlink "$f")" = /dev/null ] && continue
	systemctl disable --now --quiet "$n" 2>/dev/null
	rm -rf "$f" "$f.d"
done
systemctl disable --quiet inventory-sync.service 2>/dev/null
rm -f /etc/systemd/system/inventory-sync.service
[ "$(systemctl is-enabled apport 2>/dev/null)" = masked ] && systemctl unmask --quiet apport
systemctl daemon-reload
systemctl reset-failed
true
