pkill -f '^openssl s_server .*4433' 2>/dev/null
systemctl disable --now --quiet named 2>/dev/null
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
rm -rf $(pick "/etc/named.conf /etc/named /var/named" "/etc/bind /var/lib/bind /var/cache/bind")
[ -f "$LAB_STATE/bind.tar" ] && tar -C / -xf "$LAB_STATE/bind.tar"
is_rhel && [ -e /var/named ] && restorecon -R /etc/named.conf /etc/named /var/named 2>/dev/null
[ -n "$(state_get named-enabled)" ] && systemctl enable --now --quiet named 2>/dev/null
if [ -f "$LAB_STATE/firewalld.tar" ]; then
	rm -rf /etc/firewalld && tar -C /etc -xf "$LAB_STATE/firewalld.tar"
	firewall-cmd -q --reload
elif [ -f "$LAB_STATE/ufw.tar" ]; then
	rm -rf /etc/ufw && tar -C /etc -xf "$LAB_STATE/ufw.tar"
	ufw reload >/dev/null
fi
rm -rf /root/dns
true
