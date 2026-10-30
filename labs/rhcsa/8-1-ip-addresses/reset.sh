systemctl disable --now --quiet le-lab-watch.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-watch.service /usr/local/lib/le-lab/watch.sh
# Profiles on eth1, then the spare network itself.
nmcli -t -f UUID connection show 2>/dev/null | while read -r uuid; do
	[ "$(nmcli -g connection.interface-name connection show "$uuid" 2>/dev/null)" = eth1 ] &&
		nmcli connection delete "$uuid" >/dev/null 2>&1
done
rm -f /etc/NetworkManager/conf.d/91-le-lab-spare.conf
systemctl reload NetworkManager
systemctl disable --now --quiet le-lab-spare-net.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-spare-net.service /usr/local/lib/le-lab/spare-net.sh
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
ip link del eth1 2>/dev/null
ip netns del le-net50 2>/dev/null
true
