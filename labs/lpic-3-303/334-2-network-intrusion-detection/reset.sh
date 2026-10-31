systemctl disable --now --quiet le-lab-app.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-app.service /usr/local/lib/le-lab/httpd.py
rmdir /usr/local/lib/le-lab 2>/dev/null
rm -rf /srv/le-app /root/snort-console.txt
pkill -x snort 2>/dev/null
pkill -x iftop 2>/dev/null
systemctl stop snort ntopng 2>/dev/null
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
rm -rf /etc/snort /etc/ntopng.conf
grep -qx snort <<<"${new:-}" && rm -rf /var/log/snort
[ -f "$LAB_STATE/conf.tar" ] && tar -C / -xf "$LAB_STATE/conf.tar"
for s in $(cat "$LAB_STATE/active" 2>/dev/null); do systemctl start $s 2>/dev/null; done
systemctl daemon-reload
true
