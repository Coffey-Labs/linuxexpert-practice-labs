# Put back chrony and SELinux as they were, then remove what was installed
# since setup. greg goes with users_remove.
if [ -f "$LAB_STATE/chrony.conf" ]; then
	cp -a "$LAB_STATE/chrony.conf" /etc/chrony.conf
	systemctl try-restart chronyd 2>/dev/null
fi
if [ -f "$LAB_STATE/selinux-config" ]; then
	cp -a "$LAB_STATE/selinux-config" /etc/selinux/config
	[ "$(state_get enforce)" = Enforcing ] && setenforce 1
	[ "$(state_get enforce)" = Permissive ] && setenforce 0
	b=$(state_get boolean)
	[ -n "$b" ] && setsebool -P httpd_can_network_connect "$b"
fi
rm -f /etc/sudoers.d/le-lab-greg
if [ -f "$LAB_STATE/rpms" ]; then
	new=$(rpm -qa --qf '%{NAME}\n' | sort -u | comm -13 "$LAB_STATE/rpms" -)
	[ -n "$new" ] && dnf -y -q remove $new >/dev/null 2>&1
fi
true
