IF=$(ip -4 route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
[ -n "$IF" ] || refuse "no default route; this lab needs a working network"
pkg_installed firewalld || pkg_install firewalld
pkg_installed httpd && state_set httpd-before 1
pkg_installed httpd || pkg_install httpd
systemctl is-active --quiet firewalld && state_set firewalld-was-active 1
enabled firewalld && state_set firewalld-was-enabled 1
enabled httpd && state_set httpd-was-enabled 1
tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
systemctl enable --now --quiet firewalld
firewall-cmd -q --state
Z=$(firewall-cmd --get-zone-of-interface="$IF" 2>/dev/null || firewall-cmd --get-default-zone)
state_set zone "$Z"
# The starting point: SSH allowed as a service, no forward, no sources.
firewall-cmd -q --permanent --zone="$Z" --query-service=ssh || firewall-cmd -q --permanent --zone="$Z" --add-service=ssh
firewall-cmd -q --reload

[ -f /var/www/html/index.html ] && cp -a /var/www/html/index.html "$LAB_STATE/index.html"
echo 'Lab httpd on port 80' >/var/www/html/index.html
restorecon /var/www/html/index.html 2>/dev/null || true
systemctl enable --now --quiet httpd
peer_up
