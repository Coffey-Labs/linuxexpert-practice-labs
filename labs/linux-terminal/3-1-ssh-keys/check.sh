H=$(state_get home)
K=$H/.ssh/lab_key
BH=$(getent passwd bob | cut -d: -f6)
# key_login: log in as bob with the lab key, unlocked into a temporary copy.
key_login() {
	local d r=1
	d=$(mktemp -d)
	cp "$K" "$d/k" && chmod 600 "$d/k" && ssh-keygen -q -p -P Lab-Phrase-1 -N '' -f "$d/k" >/dev/null 2>&1 &&
		[ "$(timeout 15 ssh -o BatchMode=yes -o IdentitiesOnly=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
			-o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -i "$d/k" bob@localhost whoami </dev/null 2>/dev/null)" = bob ] && r=0
	rm -rf "$d"
	return $r
}
bad_modes() {
	local n m="bad ownership or modes for directory $BH"
	journalctl -q -u ssh --since "$(state_get start)" --no-pager 2>/dev/null | grep -qF "$m" && return 0
	n=$(cat "$LAB_STATE/auth-size" 2>/dev/null); n=${n:-0}
	[ "$(stat -c %s /var/log/auth.log)" -ge "$n" ] || n=0
	tail -c +$((n + 1)) /var/log/auth.log | grep -qF "$m"
}

task 1 "~/.ssh/lab_key: Ed25519, comment lab-key, with a passphrase"
need "$K and $K.pub exist" '[ -f "$K" ] && [ -f "$K.pub" ]'
need "ssh-keygen -l -f $K.pub ends with lab-key (ED25519)" 'ssh-keygen -l -f "$K.pub" | grep -q "lab-key (ED25519)$"'
need "$K is -rw------- and owned by student" '[ "$(stat -c "%a %U" "$K")" = "600 student" ]'
need "$K has a passphrase" '! ssh-keygen -y -P "" -f "$K"'
need "its passphrase is Lab-Phrase-1 (le-lab check needs it)" 'ssh-keygen -y -P Lab-Phrase-1 -f "$K"'

task 2 "User bob with a password, and the lab key logs in as him"
need "user bob exists" 'id bob'
need "bob has a password: passwd -S bob shows P" '[ "$(passwd -S bob | cut -d" " -f2)" = P ]'
need "bob's authorized_keys holds the lab key" 'grep -qF "$(cut -d" " -f2 "$K.pub")" "$BH/.ssh/authorized_keys"'
need "ssh -i ~/.ssh/lab_key bob@localhost whoami prints bob" key_login

task 3 "Home directory too open: found in sshd's log, then fixed"
need "sshd logged bad ownership or modes for directory $BH" bad_modes
need "$BH isn't writable by group or others" '[ -d "$BH" ] && [ -z "$(find "$BH" -maxdepth 0 -perm /022)" ]'
need "the key login works again" key_login
