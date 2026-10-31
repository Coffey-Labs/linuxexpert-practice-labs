systemctl disable --now --quiet le-lab-peer-dhcp.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-peer-dhcp.service /run/le-lab-peer-dhcp.leases
systemctl daemon-reload
for s in radiusd freeradius radvd; do systemctl disable --now --quiet $s 2>/dev/null; done
pkill -x tshark 2>/dev/null
pkill -x dumpcap 2>/dev/null
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
rm -rf /etc/raddb /etc/freeradius /etc/radvd.conf /root/radius.pcapng /tmp/le-rt
[ -f "$LAB_STATE/conf.tar" ] && tar -C / -xf "$LAB_STATE/conf.tar"
for s in $(cat "$LAB_STATE/enabled" 2>/dev/null); do systemctl enable --now --quiet $s 2>/dev/null; done
if [ -f "$LAB_STATE/firewalld.tar" ]; then
	rm -rf /etc/firewalld && tar -C /etc -xf "$LAB_STATE/firewalld.tar"
	firewall-cmd -q --reload
elif [ -f "$LAB_STATE/ufw.tar" ]; then
	rm -rf /etc/ufw && tar -C /etc -xf "$LAB_STATE/ufw.tar"
	ufw reload >/dev/null
fi
true
