SSHOPT=(-o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR)
T=$(sshd -T -f /etc/ssh/server1/sshd_config 2>/dev/null)
AK=/home/alice/.ssh/authorized_keys
key_login() { [ "$(timeout 15 runuser -u student -- ssh "${SSHOPT[@]}" alice@10.99.0.2 whoami </dev/null 2>/dev/null)" = alice ]; }
pw_refused() {
	local out
	out=$(timeout 15 runuser -u student -- ssh "${SSHOPT[@]}" -o PubkeyAuthentication=no alice@10.99.0.2 true </dev/null 2>&1)
	grep -q "Permission denied (publickey" <<<"$out" && ! grep -q password <<<"$out"
}

task 1 "student logs in to alice@server1 with a key"
need "server1's sshd is running" active le-lab-server1-sshd
need "student has a key pair" 'ls /home/student/.ssh/id_* 2>/dev/null | grep -q "\.pub$"'
need "alice's authorized_keys has student's public key" 'for k in /home/student/.ssh/id_*.pub; do grep -qF "$(cut -d" " -f2 "$k")" $AK 2>/dev/null && exit 0; done; exit 1'
need "as student, ssh -o BatchMode=yes alice@server1 whoami prints alice" key_login

task 2 "No password logins on server1; keys still work"
need "sshd -T -f /etc/ssh/server1/sshd_config prints passwordauthentication no" 'grep -qx "passwordauthentication no" <<<"$T"'
need "server1's sshd is running" active le-lab-server1-sshd
need "a login without a key is refused: Permission denied (publickey)" pw_refused
need "the key login still works" key_login

task 3 "authorized_keys too open, seen in the log, then fixed"
need "server1's sshd logged bad ownership or modes for alice's authorized_keys" 'grep -qs "bad ownership or modes for file $AK" "$LAB_STATE/bad-modes" || journalctl -q -u le-lab-server1-sshd --since "$(state_get start)" | grep -q "bad ownership or modes for file $AK"'
need "alice's authorized_keys isn't writable by group or others" '[ -f $AK ] && [ -z "$(find $AK -perm /022)" ]'
need "the key login works again" key_login
