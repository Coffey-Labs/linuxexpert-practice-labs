mkdir -p /run/sshd
T=$(sshd -T 2>/dev/null)
U=$(state_get student)
H=$(getent passwd "$U" | cut -d: -f6)
SSHOPT=(-o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR)
# login USER [ssh options]: you log in as USER with your own key.
login() { local t=$1; shift; timeout 15 runuser -u "$U" -- ssh "${SSHOPT[@]}" "$@" "$t@localhost" 'echo le-shell-ok' </dev/null 2>/dev/null | grep -q le-shell-ok; }
# has_key USER: USER's authorized_keys holds one of your public keys.
has_key() {
	local h k f
	h=$(getent passwd "$1" | cut -d: -f6)
	f=$h/.ssh/authorized_keys
	[ -f "$f" ] || return 1
	for k in "$H"/.ssh/id_*.pub; do
		[ -f "$k" ] || continue
		grep -qF "$(awk '{ print $2 }' "$k")" "$f" && return 0
	done
	return 1
}
has_password() { [ "$(passwd -S "$1" 2>/dev/null | awk '{ print $2 }')" = P ]; }

task 1 "ann and ben with keys; only group remote, with ann and you, logs in"
need "users ann and ben exist" 'id ann && id ben'
need "ann and ben have passwords" 'has_password ann && has_password ben'
need "ann's and ben's authorized_keys hold your key" 'has_key ann && has_key ben'
need "sshd -T shows allowgroups remote" 'grep -Eq "^allowgroups( .*)? remote( |$)" <<<"$T"'
need "ann and your account are in group remote" 'id -nG ann | grep -qw remote && id -nG "$U" | grep -qw remote'
need "ben isn't in group remote" '! id -nG ben | grep -qw remote'
need "ssh -o BatchMode=yes ann@localhost works with your key" 'login ann'
need "the same for ben fails" '! login ben'

task 2 "No password logins and no root logins, from a drop-in that wins"
need "sshd -T shows passwordauthentication no" 'grep -qx "passwordauthentication no" <<<"$T"'
need "sshd -T shows permitrootlogin no" 'grep -qx "permitrootlogin no" <<<"$T"'
need "a file in /etc/ssh/sshd_config.d/ sets PasswordAuthentication no" 'grep -Eiqs "^[[:space:]]*PasswordAuthentication[[:space:]]+no" /etc/ssh/sshd_config.d/*.conf'
need "ssh without a key gets Permission denied (publickey)" 'timeout 15 runuser -u "$U" -- ssh "${SSHOPT[@]}" -o PubkeyAuthentication=no ann@localhost true 2>&1 </dev/null | grep -q "Permission denied (publickey)"'

task 3 "sshd listens on 2222 as well as 22"
need "something listens on port 2222" 'listening 2222 tcp'
need "something listens on port 22" 'listening 22 tcp'
need "ssh -p 2222 ann@localhost works" 'login ann -p 2222'
need "ssh -p 22 ann@localhost still works" 'login ann -p 22'
