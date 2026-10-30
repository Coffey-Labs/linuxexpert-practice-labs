SSHOPT=(-o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR)
KH=/home/alice/.ssh/known_hosts
T=$(mktemp -d)
chmod 755 "$T"
trap 'rm -rf "$T"' EXIT
# known_current: alice's known_hosts has the peer's keys, and only its
# current ones.
known_current() {
	local h n=0
	timeout 10 ssh-keyscan -T 5 10.99.0.2 2>/dev/null | awk '{print $2, $3}' | sort -u >"$T/scan"
	[ -s "$T/scan" ] || return 1
	for h in 10.99.0.2 peer peer.lab.example; do
		ssh-keygen -F "$h" -f "$KH" 2>/dev/null | grep -v '^#' | awk '{print $2, $3}' >>"$T/known"
	done
	[ -s "$T/known" ] || return 1
	! grep -vxFf "$T/scan" "$T/known" | grep -q .
}
gpg_as() { local u=$1; shift; runuser -u "$u" -- env HOME="/home/$u" gpg --batch --no-tty "$@" </dev/null 2>&1; local r=$?; runuser -u "$u" -- env HOME="/home/$u" gpgconf --kill all >/dev/null 2>&1; return $r; }

task 1 "alice has a passphrase-protected ed25519 key the peer accepts"
need "/home/alice/.ssh/id_ed25519 exists" '[ -f /home/alice/.ssh/id_ed25519 ] && [ -f /home/alice/.ssh/id_ed25519.pub ]'
need "the key is an ed25519 key" 'ssh-keygen -lf /home/alice/.ssh/id_ed25519.pub | grep -q "(ED25519)"'
need "the key has a passphrase" '! ssh-keygen -y -P "" -f /home/alice/.ssh/id_ed25519'
need "the public key is in alice's authorized_keys" 'grep -qF "$(awk "{print \$2}" /home/alice/.ssh/id_ed25519.pub)" /home/alice/.ssh/authorized_keys'

task 2 "The peer allows keys, not passwords"
need "the peer's sshd -T shows passwordauthentication no" 'mkdir -p /run/sshd; in_peer sshd -T 2>/dev/null | grep -qx "passwordauthentication no"'
need "the running sshd on the peer offers no password logins" 'o=$(timeout 15 ssh "${SSHOPT[@]}" -o PubkeyAuthentication=no alice@10.99.0.2 true 2>&1 </dev/null); grep -q "Permission denied (" <<<"$o" && ! grep -Eq "password|keyboard-interactive" <<<"$o"'
need "the peer still takes keys" 'grep -q "publickey" <<<"$(timeout 15 ssh "${SSHOPT[@]}" -o PubkeyAuthentication=yes -i /dev/null nobody@10.99.0.2 true 2>&1 </dev/null)"'

task 3 "New host keys on the peer, and alice's known_hosts up to date"
need "the peer's ed25519 host key is new" '[ -f /etc/netns/lepeer/ssh/ssh_host_ed25519_key.pub ] && [ "$(ssh-keygen -lf /etc/netns/lepeer/ssh/ssh_host_ed25519_key.pub | awk "{print \$2}")" != "$(state_get hostkey)" ]'
need "the peer's sshd serves the new key" 'timeout 10 ssh-keyscan -T 5 -t ed25519 10.99.0.2 2>/dev/null | grep -qF "$(awk "{print \$2}" /etc/netns/lepeer/ssh/ssh_host_ed25519_key.pub)"'
need "alice's known_hosts has the peer's new keys and none of the old" known_current

task 4 "curl localhost:8000 reaches the peer's web server through an SSH tunnel"
need "the peer runs a web server on its 127.0.0.1:8000" 'in_peer ss -Hltn "sport = :8000" | grep -q "127\.0\.0\.1:8000"'
need "ssh listens on port 8000 here" 'ss -Hltnp "sport = :8000" | grep -q "\"ssh\""'
need "curl http://localhost:8000/ returns the peer's page" 'curl -s --max-time 5 http://localhost:8000/ | grep -qi "directory listing\|<html"'

task 5 "secret.txt encrypted by alice for bob, and decrypted by bob"
need "bob has alice's public key" 'gpg_as bob --list-keys alice@example.org'
need "alice has bob's public key" 'gpg_as alice --list-keys bob@example.org'
need "alice and bob have secret keys" 'gpg_as alice --list-secret-keys alice@example.org && gpg_as bob --list-secret-keys bob@example.org'
need "/home/alice/secret.txt.gpg is encrypted data" '[ -s /home/alice/secret.txt.gpg ] && ! grep -q "launch code" /home/alice/secret.txt.gpg && cp /home/alice/secret.txt.gpg "$T/s.gpg" && chmod 644 "$T/s.gpg" && gpg_as bob --list-packets "$T/s.gpg" | grep -q "pubkey enc packet"'
need "/home/bob/secret.txt matches alice's secret.txt" 'cmp -s /home/alice/secret.txt /home/bob/secret.txt'

task 6 "A detached signature of notes.txt, which no longer matches"
need "/home/alice/notes.txt.sig is a detached signature" '[ -s /home/alice/notes.txt.sig ] && gpg_as alice --list-packets /home/alice/notes.txt.sig | grep -q "signature packet" && ! gpg_as alice --list-packets /home/alice/notes.txt.sig | grep -q "literal data packet"'
need "gpg --verify reports a BAD signature from alice now" 'gpg_as alice --verify /home/alice/notes.txt.sig /home/alice/notes.txt | grep -q "BAD signature from \"Alice"'

task 7 "alice's key revoked"
need "gpg -k shows alice's key as revoked" 'gpg_as alice --with-colons --list-keys alice@example.org | grep -q "^pub:r:"'
