if [ -d /sys/fs/cgroup/lab ]; then
	[ -f /sys/fs/cgroup/lab/cgroup.kill ] && echo 1 >/sys/fs/cgroup/lab/cgroup.kill
	sleep 1
	rmdir /sys/fs/cgroup/lab 2>/dev/null
fi
systemctl stop lab-sleep.service lab-burn.service lab.slice 2>/dev/null
systemctl reset-failed lab-sleep.service lab-burn.service 2>/dev/null
rm -rf /etc/systemd/system.control/lab.slice.d /etc/systemd/system/lab.slice.d
systemctl daemon-reload
for f in /etc/security/limits.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/limits-d" 2>/dev/null || rm -f "$f"
done
sed -i -E '/^[[:space:]]*limited[[:space:]]/d' /etc/security/limits.conf
true
