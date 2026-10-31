systemctl disable --now --quiet httpd 2>/dev/null
if command -v semanage >/dev/null; then
	semanage login -d confined 2>/dev/null
	semanage fcontext -d "/srv/web(/.*)?" 2>/dev/null
	semanage port -d -t http_port_t -p tcp 8089 2>/dev/null
	semanage permissive -d httpd_t 2>/dev/null
fi
semodule -r labweb >/dev/null 2>&1
c=$(state_get cgi)
[ -n "$c" ] && [ "$(getsebool httpd_enable_cgi | awk '{print $NF}')" != "$c" ] && setsebool -P httpd_enable_cgi "$c"
pkill -KILL -u confined 2>/dev/null
rm -rf /srv/web /root/selinux /var/www/cgi-bin/lab.sh /etc/httpd/conf.d/lab.conf
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
if [ -f "$LAB_STATE/httpd.tar" ]; then
	rm -rf /etc/httpd && tar -C /etc -xf "$LAB_STATE/httpd.tar"
	[ -n "$(state_get httpd-enabled)" ] && systemctl enable --now --quiet httpd
else
	rm -rf /etc/httpd
fi
true
