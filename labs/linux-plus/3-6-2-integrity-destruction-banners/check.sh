F=/usr/share/zoneinfo/Pacific/Pitcairn
verify_clean() {
	if is_rhel; then rpm -V "$(rpm -qf $F)" | grep -q "$F" && return 1; return 0
	else dpkg --verify "$(dpkg -S $F | cut -d: -f1)" | grep -q "$F" && return 1; return 0; fi
}
mkdir -p /run/sshd

task 1 "The changed file found and restored"
need "/root/lab-answers/1 has its path" '[ "$(answer 1)" = "${F,,}" ]'
need "its package verifies clean again" verify_clean

task 2 "AIDE reports a new file in /etc/ssh" rhel
C=/root/lab-aide.conf
need "$C keeps the database in /root/lab-aide.db" 'grep -Eq "^database_in=file:/root/lab-aide\.db$" '$C' && grep -Eq "^database_out=file:/root/lab-aide\.db\.new$" '$C
need "it watches /etc/ssh with p+u+g+s+sha256" 'grep -Eq "^/etc/ssh[[:space:]]+p\+u\+g\+s\+sha256$" '$C
need "/root/lab-aide.db exists" '[ -s /root/lab-aide.db ]'
need "/etc/ssh/lab-new-file exists" '[ -e /etc/ssh/lab-new-file ]'
need "aide --check reports it as added" 'aide -c '$C' --check 2>/dev/null | grep -q "/etc/ssh/lab-new-file"'

task 3 "A pre-login SSH banner from /etc/issue.net"
need "/etc/issue.net has the banner text" 'grep -qx "Authorized use only. Activity is monitored." /etc/issue.net'
need "a drop-in in /etc/ssh/sshd_config.d/ sets it" 'grep -rqsE "^[[:space:]]*Banner[[:space:]]+/etc/issue\.net" /etc/ssh/sshd_config.d/'
need "sshd -T shows banner /etc/issue.net" 'sshd -T 2>/dev/null | grep -qx "banner /etc/issue.net"'
need "ssh localhost shows the banner" 'timeout 10 ssh -o BatchMode=yes -o PreferredAuthentications=none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null le-nobody@localhost 2>&1 </dev/null | grep -q "Authorized use only"'

task 4 "/dev/loop40 wiped to zeros"
need "/dev/loop40 is all zeros" 'cmp -s -n $((64 * 1024 * 1024)) /dev/loop40 /dev/zero'
