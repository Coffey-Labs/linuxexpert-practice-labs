keys_new() {
	local k n=0
	for k in /etc/ssh/ssh_host_*_key.pub; do
		[ -f "$k" ] || continue
		grep -qxF "$(ssh-keygen -lf "$k" | awk '{print $2}')" "$LAB_STATE/host-keys" && return 1
		n=$((n + 1))
	done
	[ "$n" -gt 0 ]
}
sshd_up() { systemctl is-active --quiet sshd || systemctl is-active --quiet ssh || systemctl is-active --quiet ssh.socket; }
# The keys sshd offers match the files.
sshd_serves() {
	local f
	f=$(ssh-keyscan -t ed25519 127.0.0.1 2>/dev/null | ssh-keygen -lf - 2>/dev/null | awk '{print $2}')
	[ -n "$f" ] && [ "$f" = "$(ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub | awk '{print $2}')" ]
}

task 1 "The hypervisor named"
need "/root/lab-answers/1 names what systemd-detect-virt reports" '[ "$(answer 1)" = "$(systemd-detect-virt)" ]'

task 2 "New machine ID, SSH host keys and hostname"
need "/etc/machine-id is new" '[ -s /etc/machine-id ] && [ "$(cat /etc/machine-id)" != "$(state_get machine-id)" ]'
need "every SSH host key is new" keys_new
need "sshd is running" sshd_up
need "sshd offers the new ed25519 key" sshd_serves
need "the hostname is new" '[ "$(hostnamectl hostname 2>/dev/null || hostname)" != "$(state_get hostname)" ]'
need "the new hostname is in /etc/hostname, so it stays after a reboot" '[ "$(tr -d "[:space:]" </etc/hostname)" = "$(hostnamectl hostname 2>/dev/null || hostname)" ]'
