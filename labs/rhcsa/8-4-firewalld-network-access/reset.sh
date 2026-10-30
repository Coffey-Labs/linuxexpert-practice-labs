systemctl disable --now --quiet le-lab-watch.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-watch.service /usr/local/lib/le-lab/watch.sh
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
if [ -f "$LAB_STATE/firewalld.tar" ]; then
	rm -rf /etc/firewalld
	tar -C /etc -xf "$LAB_STATE/firewalld.tar"
fi
if [ -n "$(state_get firewalld-was-active)" ]; then
	firewall-cmd -q --reload
else
	systemctl stop firewalld
fi
[ -n "$(state_get firewalld-was-enabled)" ] || systemctl disable --quiet firewalld 2>/dev/null
true
