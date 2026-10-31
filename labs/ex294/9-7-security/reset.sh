# greg (with his project) goes with users_remove. Here: Apache, the SELinux
# rules and firewall rules the tasks add, then what the tasks and setup
# installed.
rm -f /etc/sudoers.d/le-lab-greg
systemctl disable --now --quiet httpd 2>/dev/null
if [ "$(getenforce 2>/dev/null)" = Permissive ]; then
	setenforce 1
	sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
fi
if command -v semanage >/dev/null; then
	semanage fcontext -l -C 2>/dev/null | awk '$1 ~ /^\/srv\/www/ {print $1}' | sort -u |
		while read -r r; do semanage fcontext -d "$r" 2>/dev/null; done
	semanage port -l -C 2>/dev/null | grep -Eq '^http_port_t +tcp +.*\b8888\b' &&
		semanage port -d -t http_port_t -p tcp 8888 2>/dev/null
fi
case $(state_get boolean) in
on) setsebool -P httpd_can_network_connect on ;;
*) setsebool -P httpd_can_network_connect off ;;
esac
rm -rf /srv/www
if [ -f "$LAB_STATE/firewalld" ] && active firewalld; then
	[ -f "$LAB_STATE/had-http" ] || firewall-cmd -q --permanent --remove-service=http 2>/dev/null
	[ -f "$LAB_STATE/had-8888" ] || firewall-cmd -q --permanent --remove-port=8888/tcp 2>/dev/null
	firewall-cmd -q --reload
fi
if [ -f "$LAB_STATE/rpms" ]; then
	new=$(comm -13 "$LAB_STATE/rpms" <(rpm -qa --qf '%{NAME}\n' | sort -u))
	[ -z "$new" ] || dnf -y -q remove $new >/dev/null 2>&1
fi
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
# Setup made sure there was no Apache before.
pkg_installed httpd || rm -rf /etc/httpd /var/www /var/log/httpd
systemctl daemon-reload
true
