user_add alice

# No web server running yet (tasks 2 and 3).
for s in nginx httpd apache2; do
	systemctl disable --quiet --now "$s" 2>/dev/null || true
done

# A running print service for task 4.
if ! pkg_installed "$(pick cups cups-daemon)"; then
	say "${C_DIM}Installing cups...${C_0}"
	if is_rhel; then
		dnf -y -q --setopt=install_weak_deps=False install cups >/dev/null
	else
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq --no-install-recommends install cups-daemon >/dev/null 2>&1 ||
			{ apt-get -qq update >/dev/null && DEBIAN_FRONTEND=noninteractive apt-get -y -qq --no-install-recommends install cups-daemon >/dev/null; }
	fi
fi
systemctl unmask --quiet cups.service 2>/dev/null || true
systemctl enable --quiet --now cups.service

# A graphical default target for task 5.
state_set default-target "$(systemctl get-default)"
systemctl set-default --quiet graphical.target
