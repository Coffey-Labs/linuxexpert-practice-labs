is_debian && mkdir -p /run/sshd
T=$(sshd -T 2>/dev/null)
K=/home/kim/.ssh/lab_ed25519
SSHOPT=(-o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR)
key_login() { runuser -u kim -- timeout 15 ssh "${SSHOPT[@]}" -i $K kim@10.99.0.1 'echo le-shell-ok' </dev/null | grep -q le-shell-ok; }
# The methods sshd offers kim once keys are left out.
no_pw() { timeout 15 ssh "${SSHOPT[@]}" -o PubkeyAuthentication=no -o GSSAPIAuthentication=no kim@10.99.0.1 true 2>&1 </dev/null | grep 'Permission denied' | grep -vqE 'password|keyboard-interactive'; }

task 1 "kim's ed25519 key installed and used"
need "$K is an ed25519 key without a passphrase" 'ssh-keygen -y -P "" -f '$K' | grep -q "^ssh-ed25519 "'
need "its public half is in kim's authorized_keys" 'grep -qF "$(cut -d" " -f2 '$K'.pub)" /home/kim/.ssh/authorized_keys'
need "~/.ssh is 700 and authorized_keys 600, both kim's" '[ "$(stat -c %a:%U /home/kim/.ssh)" = 700:kim ] && [ "$(stat -c %a:%U /home/kim/.ssh/authorized_keys)" = 600:kim ]'
need "kim logs in to 10.99.0.1 with the key" key_login

task 2 "sshd: no password, keyboard-interactive or root logins"
need "sshd -T shows passwordauthentication no" 'grep -qx "passwordauthentication no" <<<"$T"'
need "sshd -T shows kbdinteractiveauthentication no" 'grep -qx "kbdinteractiveauthentication no" <<<"$T"'
need "sshd -T shows permitrootlogin no" 'grep -qx "permitrootlogin no" <<<"$T"'

task 3 "Password logins refused, the key still works"
need "sshd offers kim no password login" no_pw
need "kim still logs in with the key" key_login

task 4 "Port 19090 on the peer forwarded to 9090 on this VM's localhost"
need "curl http://localhost:19090/ on the peer returns the page" 'in_peer curl -s --max-time 5 http://localhost:19090/ | grep -q "Lab console"'
