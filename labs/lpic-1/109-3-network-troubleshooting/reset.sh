# Any listener left on port 9000.
for pid in $(ss -Htlnp 'sport = :9000' | grep -o 'pid=[0-9]*' | cut -d= -f2 | sort -u); do
	kill "$pid" 2>/dev/null
done
# The firewall, as it was.
if [ -n "$(state_get firewalld)" ] && [ -f "$LAB_STATE/firewalld.tar" ]; then
	rm -rf /etc/firewalld
	tar -C /etc -xf "$LAB_STATE/firewalld.tar"
	systemctl is-active --quiet firewalld && firewall-cmd -q --reload
elif [ -n "$(state_get ufw)" ] && [ -f "$LAB_STATE/ufw.tar" ]; then
	rm -rf /etc/ufw
	tar -C /etc -xf "$LAB_STATE/ufw.tar"
	ufw reload >/dev/null
fi
true
