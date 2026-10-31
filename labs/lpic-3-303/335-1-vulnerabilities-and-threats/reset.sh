# The honeypot: whatever listens on port 2323 from /root/threats.
for pid in $(ss -ltnpH "sport = :2323" 2>/dev/null | grep -o 'pid=[0-9]*' | cut -d= -f2 | sort -u); do
	kill "$pid" 2>/dev/null
done
rm -rf /root/threats /root/lab-answers/1 /root/lab-answers/3 /root/lab-answers/5
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
