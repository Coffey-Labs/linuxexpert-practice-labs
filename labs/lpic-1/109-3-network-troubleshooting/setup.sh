listening 9000 tcp && refuse "something listens on TCP port 9000 already; stop it first"
peer_up
if systemctl is-active --quiet firewalld; then
	tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
	state_set firewalld 1
elif command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw
	state_set ufw 1
fi
# The fault: this VM's end of the link to the peer is down.
ip link set le-host down
true
