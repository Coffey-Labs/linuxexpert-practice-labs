systemctl disable --now --quiet le-lab-reindexd.service data.mount 2>/dev/null
rm -f /etc/systemd/system/le-lab-reindexd.service /etc/systemd/system/data.mount /usr/local/sbin/reindexd
rmdir /data 2>/dev/null
# Scheduler rules that name the lab's disks.
for f in /etc/udev/rules.d/*.rules; do
	[ -f "$f" ] && grep -q 'loop4' "$f" && grep -q scheduler "$f" && rm -f "$f"
done
udevadm control --reload 2>/dev/null
# sysstat back as it was.
for u in sysstat sysstat-collect.timer sysstat-summary.timer; do
	if grep -qx "$u" "$LAB_STATE/sysstat-enabled" 2>/dev/null; then
		systemctl enable --now --quiet "$u"
	else
		systemctl disable --now --quiet "$u" 2>/dev/null
	fi
done
systemctl daemon-reload
true
