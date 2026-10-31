command -v nft >/dev/null && nft delete table inet scanlab 2>/dev/null
rm -rf /root/scans
rm -f /etc/nginx/conf.d/lab.conf
if [ -n "$(state_get nginx-enabled)" ]; then
	systemctl restart nginx 2>/dev/null
else
	systemctl disable --now --quiet nginx 2>/dev/null
fi
[ -n "$(state_get semanage-8081)" ] && semanage port -d -t http_port_t -p tcp 8081 2>/dev/null
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
if [ -f "$LAB_STATE/firewalld.tar" ]; then
	rm -rf /etc/firewalld && tar -C /etc -xf "$LAB_STATE/firewalld.tar"
	firewall-cmd -q --reload
elif [ -f "$LAB_STATE/ufw.tar" ]; then
	rm -rf /etc/ufw && tar -C /etc -xf "$LAB_STATE/ufw.tar"
	ufw reload >/dev/null
fi
true
