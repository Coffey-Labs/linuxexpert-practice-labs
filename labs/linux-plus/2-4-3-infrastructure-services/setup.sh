if is_rhel; then
	pkg_installed unbound && state_set had-unbound 1
	[ -n "$(state_get had-unbound)" ] && [ -d /etc/unbound ] && tar -C /etc -cf "$LAB_STATE/unbound.tar" unbound
	command -v dig >/dev/null || pkg_install bind-utils
	if systemctl is-active --quiet firewalld; then
		tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
	fi
fi
peer_up
