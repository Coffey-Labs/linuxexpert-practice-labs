for p in /srv/jail /root/sshca /usr/local/bin/lab-python /etc/ssh/revoked.krl; do
	[ -e $p ] && refuse "$p already exists; move it away and start again"
done
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
user_add certuser
# Saved for reset: sshd's configuration, USBGuard's.
tar -C /etc -cf "$LAB_STATE/ssh.tar" ssh
if pkg_installed usbguard; then
	[ -d /etc/usbguard ] && tar -C /etc -cf "$LAB_STATE/usbguard.tar" usbguard
	enabled usbguard && state_set usbguard-enabled 1
fi
true
