nft delete table inet lab 2>/dev/null
if command -v iptables >/dev/null; then
	iptables -F; iptables -t nat -F; iptables -P INPUT ACCEPT
fi
command -v ipset >/dev/null && ipset destroy blocklist 2>/dev/null
systemctl disable --now --quiet le-lab-web8080.service le-lab-web8081.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-web8080.service /etc/systemd/system/le-lab-web8081.service /usr/local/lib/le-lab/httpd.py
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
rm -rf /srv/le-fw /root/fw
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
[ -n "$(state_get firewalld-was-active)" ] && systemctl start firewalld
[ -n "$(state_get ufw-was-active)" ] && ufw --force enable >/dev/null
true
