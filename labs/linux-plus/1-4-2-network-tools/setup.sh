IF=$(ip -4 route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
[ -n "$IF" ] || refuse "no default route; this lab needs a working network"
peer_up
# What the firewall allowed before, so that reset takes out only the lab's ports.
if systemctl is-active --quiet firewalld; then
	for p in 9000 5201; do firewall-cmd -q --query-port=$p/tcp && state_set fw-had-$p 1; done
elif command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	for p in 9000 5201; do ufw status | grep -Eq "^$p(/tcp)?[[:space:]].*ALLOW" && state_set ufw-had-$p 1; done
fi
true
# Reset takes out again what task 4 installs, so that the lab starts over.
for p in iperf3 $(pick nmap-ncat netcat-openbsd); do
	pkg_installed "$p" || printf '%s\n' "$p" >>"$LAB_STATE/not-installed"
done
