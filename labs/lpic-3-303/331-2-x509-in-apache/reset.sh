pkill -f '^openssl ocsp' 2>/dev/null
SVC=$(pick httpd apache2) D=$(pick /etc/httpd /etc/apache2)
systemctl disable --now --quiet $SVC 2>/dev/null
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
# Apache's configuration as it was, or none.
rm -rf $D /var/www/alpha /var/www/beta
if [ -f "$LAB_STATE/apache.tar" ]; then
	tar -C / -xf "$LAB_STATE/apache.tar"
	[ -n "$(state_get was-enabled)" ] && systemctl enable --now --quiet $SVC
fi
if is_rhel; then
	[ -n "$(state_get had-nc)" ] || setsebool -P httpd_can_network_connect off 2>/dev/null
	[ -s "$LAB_STATE/port-8888" ] || semanage port -d -p tcp 8888 2>/dev/null
fi
rm -rf /root/tls /tmp/le-s.out
true
