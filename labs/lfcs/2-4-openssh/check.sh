is_debian && mkdir -p /run/sshd
T=$(sshd -T 2>/dev/null)
SSHOPT=(-o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR)
# key_login USER [ssh options]: USER logs in with their lab key and runs a command.
key_login() { local u=$1; shift; timeout 15 ssh "${SSHOPT[@]}" -i /root/lab-keys/$u "$@" $u@localhost 'echo le-shell-ok' </dev/null | grep -q le-shell-ok; }
sam_sftp() { timeout 15 sftp "${SSHOPT[@]}" -i /root/lab-keys/sam -b - sam@localhost; }

task 1 "Key logins only, no root, only group sshusers"
need "sshd -T shows passwordauthentication no" 'grep -qx "passwordauthentication no" <<<"$T"'
need "sshd -T shows permitrootlogin no" 'grep -qx "permitrootlogin no" <<<"$T"'
need "sshd -T shows allowgroups sshusers" 'grep -Eq "^allowgroups( .*)? sshusers( |$)" <<<"$T"'
need "alice (in sshusers) logs in with her key" 'key_login alice'
need "bob isn't in sshusers" '! id -nG bob | grep -qw sshusers'
need "bob (not in sshusers) is refused" '! key_login bob'

task 2 "sshd listens on 2222 as well as 22"
need "something listens on port 2222" 'listening 2222 tcp'
need "something listens on port 22" 'listening 22 tcp'
need "ssh -p 2222 localhost logs in" 'key_login alice -p 2222'
need "ssh -p 22 localhost still logs in" 'key_login alice -p 22'
if is_rhel && [ "$(state_get selinux)" = Enforcing ]; then
	need "SELinux is still enforcing" '[ "$(getenforce)" = Enforcing ]'
fi

task 3 "ssh lab logs in to the peer as alice with her key"
need "ssh lab runs a command on the peer as alice, without a password" 'timeout 15 ssh "${SSHOPT[@]}" lab "id -un; ip -4 -o addr show" </dev/null | tr -s " " >/tmp/le-lab-ssh.out; grep -qx alice /tmp/le-lab-ssh.out && grep -q " 10\.99\.0\.2/" /tmp/le-lab-ssh.out'
rm -f /tmp/le-lab-ssh.out

task 4 "curl localhost:8080 reaches the peer's web server through a tunnel"
need "curl localhost:8080 returns the peer's page" 'curl -s --max-time 5 http://localhost:8080/ | grep -q "Peer web server"'

task 5 "Group sftponly: SFTP only, chrooted in /srv/sftp/<user>"
need "sam can log in with sftp" 'echo pwd | sam_sftp'
need "sam's sftp starts in a chroot at /srv/sftp/sam" 'echo pwd | sam_sftp | grep -q "Remote working directory: /$"'
need "sam can write in /srv/sftp/sam/upload" 'f=le-check-$$; echo "put /etc/hostname upload/$f" | sam_sftp && [ -f /srv/sftp/sam/upload/$f ]; r=$?; rm -f /srv/sftp/sam/upload/$f; exit $r'
need "ssh as sam gives no shell" '! key_login sam'
