if is_rhel; then
	if [ -n "$(state_get had-unbound)" ]; then
		if [ -f "$LAB_STATE/unbound.tar" ]; then rm -rf /etc/unbound; tar -C /etc -xf "$LAB_STATE/unbound.tar"; fi
		systemctl try-restart unbound 2>/dev/null
	elif pkg_installed unbound; then
		systemctl disable --now --quiet unbound 2>/dev/null
		dnf -y -q remove unbound >/dev/null
		rm -rf /etc/unbound
	fi
	if [ -f "$LAB_STATE/firewalld.tar" ]; then
		rm -rf /etc/firewalld
		tar -C /etc -xf "$LAB_STATE/firewalld.tar"
		systemctl is-active --quiet firewalld && firewall-cmd -q --reload
	fi
fi
true
