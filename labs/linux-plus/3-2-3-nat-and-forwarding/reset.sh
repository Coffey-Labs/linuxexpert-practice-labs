if [ -f "$LAB_STATE/firewalld.tar" ]; then
	rm -rf /etc/firewalld
	tar -C /etc -xf "$LAB_STATE/firewalld.tar"
	command -v restorecon >/dev/null && restorecon -R /etc/firewalld
fi
if [ -n "$(state_get firewalld-was-active)" ]; then
	firewall-cmd -q --reload
else
	systemctl disable --now --quiet firewalld
fi
# Forwarding, as it was.
for f in /etc/sysctl.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/sysctl-d" 2>/dev/null && continue
	grep -q ip_forward "$f" && rm -f "$f"
done
v=$(state_get ip-forward)
[ -n "$v" ] && sysctl -qw net.ipv4.ip_forward="$v"
true
