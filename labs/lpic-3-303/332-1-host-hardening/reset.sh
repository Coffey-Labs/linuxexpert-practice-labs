if [ -f "$LAB_STATE/ssh.tar" ]; then
	rm -f /etc/ssh/sshd_config.d/* /etc/ssh/revoked.krl /etc/ssh/*-cert.pub
	tar -C /etc -xf "$LAB_STATE/ssh.tar"
	if is_rhel; then
		systemctl restart sshd
	else
		systemctl restart ssh.socket 2>/dev/null
		systemctl restart ssh.service 2>/dev/null
	fi
fi
rm -rf /root/sshca /srv/jail /usr/local/bin/lab-python
pkg_installed usbguard && [ ! -f "$LAB_STATE/usbguard.tar" ] && systemctl disable --now --quiet usbguard 2>/dev/null
# The packages installed since setup started, and only those: not the
# dependencies they leave unneeded that were there before.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
if [ -s "$LAB_STATE/pkgs-before" ]; then
	new=$(pkgs_now | comm -13 "$LAB_STATE/pkgs-before" - | grep -Ev '^(kernel|linux-)')
	if [ -n "$new" ]; then
		say "Removing the packages installed since the lab started..."
		if is_rhel; then
			dnf -y -q remove --setopt=clean_requirements_on_remove=False $new >/dev/null 2>&1
		else
			DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $new >/dev/null 2>&1
		fi
	fi
fi
if ! pkg_installed usbguard; then
	rm -rf /etc/usbguard /var/log/usbguard
elif [ -f "$LAB_STATE/usbguard.tar" ]; then
	rm -rf /etc/usbguard && tar -C /etc -xf "$LAB_STATE/usbguard.tar"
	if [ -n "$(state_get usbguard-enabled)" ]; then systemctl restart usbguard; else systemctl disable --now --quiet usbguard; fi
fi
true
