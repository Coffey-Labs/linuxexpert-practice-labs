IF=$(state_get if)
Z=$(firewall-cmd --get-zone-of-interface="$IF" 2>/dev/null)

task 1 "le-host in zone internal, persistently"
need "firewalld is running and enabled" 'active firewalld && enabled firewalld'
need "le-host is in zone internal now" '[ "$(firewall-cmd --get-zone-of-interface=le-host)" = internal ]'
need "le-host is in zone internal permanently" '[ "$(firewall-cmd --permanent --get-zone-of-interface=le-host)" = internal ]'

task 2 "Policy int-to-pub and masquerading, persistently"
for p in --permanent ""; do
	w=permanently; [ -z "$p" ] && w=now
	need "policy int-to-pub exists ($w)" "firewall-cmd $p --info-policy int-to-pub"
	need "it goes from internal to public ($w)" "firewall-cmd $p --info-policy int-to-pub | grep -Eq '^[[:space:]]*ingress-zones: (.* )?internal( |\$)' && firewall-cmd $p --info-policy int-to-pub | grep -Eq '^[[:space:]]*egress-zones: (.* )?public( |\$)'"
	need "its target is ACCEPT ($w)" "firewall-cmd $p --info-policy int-to-pub | grep -Eq '^[[:space:]]*target: ACCEPT'"
done
need "masquerading is on in the main interface's zone, now and permanently" 'firewall-cmd --zone="$Z" --query-masquerade && firewall-cmd --permanent --zone="$Z" --query-masquerade'
need "IPv4 forwarding is on" '[ "$(sysctl -n net.ipv4.ip_forward)" = 1 ]'

task 3 "The peer reaches the internet through this VM"
need "the peer can ping 9.9.9.9" 'in_peer ping -c1 -W3 9.9.9.9 || in_peer ping -c1 -W3 9.9.9.9'
