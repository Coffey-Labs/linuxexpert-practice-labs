for u in le-lab-metricsd le-lab-web le-lab-dns le-lab-trouble; do
	systemctl disable --now --quiet "$u.service" 2>/dev/null
	rm -rf "/etc/systemd/system/$u.service" "/etc/systemd/system/$u.service.d"
done
systemctl daemon-reload
if systemctl is-active --quiet firewalld; then
	for i in le-host le-far; do
		firewall-cmd -q --zone=trusted --remove-interface=$i 2>/dev/null
		firewall-cmd -q --permanent --zone=trusted --remove-interface=$i 2>/dev/null
	done
fi
[ -n "$(state_get ufw)" ] && ufw delete allow in on le-host >/dev/null 2>&1
ip link del le-far 2>/dev/null
rm -f /etc/NetworkManager/conf.d/91-le-lab-trouble.conf
rm -f /etc/netns/lepeer/network /etc/netns/lepeer/resolv.conf
rmdir /etc/netns/lepeer /etc/netns 2>/dev/null
rm -rf /srv/le-web /usr/local/lib/le-lab/trouble-net.sh /usr/local/lib/le-lab/metricsd.py /usr/local/lib/le-lab/httpd.py
rmdir /usr/local/lib/le-lab 2>/dev/null
true
