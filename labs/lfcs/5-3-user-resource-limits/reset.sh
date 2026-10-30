systemctl disable --now --quiet lab-worker.service 2>/dev/null
rm -f /etc/systemd/system/lab-worker.service /usr/local/bin/lab-worker
rm -rf /etc/systemd/system/lab-worker.service.d
# Put the limits files back as they were.
saved=$LAB_STATE/saved
if [ -d "$saved/etc/security/limits.d" ]; then
	cp -a "$saved/etc/security/limits.conf" /etc/security/limits.conf
	rm -rf /etc/security/limits.d
	cp -a "$saved/etc/security/limits.d" /etc/security/limits.d
	command -v restorecon >/dev/null && restorecon -R /etc/security
fi
# Slice settings for alice, and memory caps for every user.
uid=$(state_get alice-uid)
if [ -n "$uid" ]; then
	rm -rf /etc/systemd/system.control/user-$uid.slice.d /run/systemd/system.control/user-$uid.slice.d \
		/etc/systemd/system/user-$uid.slice.d
fi
for f in /etc/systemd/system/user-.slice.d/*.conf; do
	[ -f "$f" ] && grep -q '^MemoryMax' "$f" && rm -f "$f"
done
rmdir /etc/systemd/system/user-.slice.d 2>/dev/null
systemctl daemon-reload
users_remove
groupdel students 2>/dev/null
true
