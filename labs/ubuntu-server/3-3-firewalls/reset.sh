for u in le-lab-web le-lab-peer-sshd le-lab-peer-web le-lab-peer-iptables; do
	systemctl disable --now --quiet "$u.service" 2>/dev/null
	rm -rf "/etc/systemd/system/$u.service" "/etc/systemd/system/$u.service.d"
done
systemctl daemon-reload
rm -rf /srv/le-web /srv/le-peer-web /usr/local/lib/le-lab/httpd.py /etc/netns/lepeer/iptables.rules
rmdir /usr/local/lib/le-lab /etc/netns/lepeer /etc/netns 2>/dev/null
# ufw as it was.
ufw --force disable >/dev/null 2>&1
if [ -f "$LAB_STATE/ufw.tar" ]; then
	rm -rf /etc/ufw
	tar -C /etc -xf "$LAB_STATE/ufw.tar"
fi
if [ -n "$(state_get ufw-was-active)" ]; then
	ufw --force enable >/dev/null
fi
true
