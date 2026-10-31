IF=$(state_get if)
is_debian && mkdir -p /run/sshd
SSHOPT=(-o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR)
key_login() { timeout 15 ssh "${SSHOPT[@]}" -o BatchMode=yes -o PreferredAuthentications=publickey alice@localhost id -un </dev/null | grep -qx alice; }
# A login as alice with her right password, typed by an askpass helper.
password_login() {
	local ap=/run/le-lab-askpass r
	printf '#!/bin/sh\necho Lab-Pass-1\n' >$ap && chmod 700 $ap
	SSH_ASKPASS=$ap SSH_ASKPASS_REQUIRE=force DISPLAY=none timeout 15 setsid -w ssh "${SSHOPT[@]}" \
		-o PubkeyAuthentication=no -o PreferredAuthentications=password,keyboard-interactive \
		-o NumberOfPasswordPrompts=1 alice@localhost id -un </dev/null 2>/dev/null | grep -qx alice
	r=$?; rm -f $ap; return $r
}

# The firewall: firewalld if it's running, otherwise ufw.
fwd=''; active firewalld && fwd=1
ufw_on() { command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; }
zones() { { firewall-cmd --get-zone-of-interface="$IF" 2>/dev/null || firewall-cmd --get-default-zone; firewall-cmd --get-default-zone; } | sort -u; }
only_ssh() {
	local z p
	if [ -n "$fwd" ]; then
		for z in $(zones); do
			for p in "" --permanent; do
				firewall-cmd $p --zone="$z" --list-services | tr ' ' '\n' | grep -Evx 'ssh|dhcpv6-client|' && return 1
				[ -z "$(firewall-cmd $p --zone="$z" --list-ports)" ] || return 1
				[ "$(firewall-cmd $p --zone="$z" --get-target)" != ACCEPT ] || return 1
			done
		done
		return 0
	fi
	! ufw status | grep ALLOW | grep -v FWD | grep -Evq '^(22(/tcp)?|OpenSSH)[[:space:]]' &&
		ufw status verbose | grep -Eq 'Default: (deny|reject) \(incoming\)'
}
peer_ssh() { in_peer timeout 5 bash -c 'exec 3<>/dev/tcp/10.99.0.1/22; head -c 4 <&3' 2>/dev/null | grep -q SSH; }
peer_web() { in_peer curl -s --max-time 5 http://10.99.0.1:8080/ | grep -q "Lab web server"; }
hash_line() { sed -n "${1}p" /root/lab-answers/3 2>/dev/null | awk '{print tolower($1)}'; }

task 1 "Key login to alice; password logins off"
need "ssh alice@localhost logs root in with a key" key_login
need "sshd -T shows passwordauthentication no" 'sshd -T 2>/dev/null | grep -qx "passwordauthentication no"'
need "a file in /etc/ssh/sshd_config.d sets PasswordAuthentication no" 'grep -rhiEv "^[[:space:]]*#" /etc/ssh/sshd_config.d 2>/dev/null | grep -iEq "^[[:space:]]*PasswordAuthentication[[:space:]]+no"'
need "the running sshd refuses alice's password" '! password_login'

task 2 "The host firewall is on and allows only SSH"
need "firewalld or ufw is on" '[ -n "$fwd" ] || ufw_on'
need "it's on at boot" 'if [ -n "$fwd" ]; then enabled firewalld; else grep -qx "ENABLED=yes" /etc/ufw/ufw.conf; fi'
need "it allows only SSH in, now and permanently" only_ssh
need "the web server on 8080 is still running" active le-lab-app.service
need "the peer can't reach port 8080" '! peer_web'
need "the peer can still reach SSH" peer_ssh

task 3 "Hashes of /root/hash-me.txt before and after a one-character change"
need "line 1 of /root/lab-answers/3 is the hash from before" '[ "$(hash_line 1)" = "$(sha256sum <"$LAB_STATE/hash-me.txt" | cut -d" " -f1)" ]'
need "exactly one character of /root/hash-me.txt changed" '[ "$(cmp -l "$LAB_STATE/hash-me.txt" /root/hash-me.txt 2>/dev/null | wc -l)" = 1 ] && [ "$(stat -c %s /root/hash-me.txt)" = "$(stat -c %s "$LAB_STATE/hash-me.txt")" ]'
need "line 2 is the hash after the change" '[ "$(hash_line 2)" = "$(sha256sum </root/hash-me.txt | cut -d" " -f1)" ]'

task 4 "/root/secret.txt encrypted with a passphrase, deleted and decrypted again"
need "/root/secret.txt.gpg is encrypted with a passphrase" 'gpg --batch --list-packets /root/secret.txt.gpg </dev/null 2>/dev/null | grep -q "symkey enc packet"'
need "/root/secret.txt is back, with its original contents" '[ "$(sha256sum </root/secret.txt)" = "$(state_get secret-sha)" ]'
need "it was deleted and decrypted again" '[ "$(stat -c "%i %.9W" /root/secret.txt)" != "$(state_get secret-id)" ]'

task 5 "CVE-2024-3094's CVSS score in /root/lab-answers/5"
need "the answer is the score the NVD shows" '[[ "$(answer 5)" =~ ^10(\.0)?$ ]]'
