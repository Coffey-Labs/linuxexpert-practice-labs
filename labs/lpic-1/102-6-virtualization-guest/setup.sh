state_set machine-id "$(cat /etc/machine-id)"
state_set hostname "$(hostnamectl hostname 2>/dev/null || hostname)"
for k in /etc/ssh/ssh_host_*_key.pub; do
	[ -f "$k" ] && ssh-keygen -lf "$k" | awk '{print $2}'
done >"$LAB_STATE/host-keys"
[ -s "$LAB_STATE/host-keys" ] || refuse "no SSH host keys in /etc/ssh; this lab needs sshd."
