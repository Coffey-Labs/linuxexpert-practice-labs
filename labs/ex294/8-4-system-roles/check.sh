# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
P=/home/greg/ansible
OUT=$LAB_STATE/check.out
# sources: chronyc lists at least one server, trying for up to 20 seconds.
sources() { local i; for i in $(seq 10); do [ "$(chronyc -n sources 2>/dev/null | grep -c '^[\^=]')" -gt 0 ] && return 0; sleep 2; done; return 1; }

task 1 "The timesync role: a pool, chronyd using it, and no changes on a second run"
need "/home/greg/ansible/timesync.yml exists" '[ -f $P/timesync.yml ]'
need "/etc/chrony.conf was written by the timesync role (Ansible managed)" 'grep -q "Ansible managed" /etc/chrony.conf'
need "/etc/chrony.conf has a pool line" 'grep -Eq "^pool [^ ]+" /etc/chrony.conf'
need "chronyd is running" active chronyd
need "chronyc sources lists servers" sources
need "a second run of timesync.yml reports changed=0" 'ans ansible-playbook timesync.yml >"$OUT" 2>&1; grep -Eq "^localhost +: ok=[0-9]+ +changed=0 +unreachable=0 +failed=0" "$OUT"'

task 2 "The selinux role: enforcing, and httpd_can_network_connect on for good"
need "/home/greg/ansible/selinux.yml exists" '[ -f $P/selinux.yml ]'
need "getenforce says Enforcing" '[ "$(getenforce)" = Enforcing ]'
need "/etc/selinux/config says SELINUX=enforcing" 'grep -qx "SELINUX=enforcing" /etc/selinux/config'
need "getsebool httpd_can_network_connect says on" 'getsebool httpd_can_network_connect | grep -q "on$"'
need "the boolean is set persistently" 'grep -qx "httpd_can_network_connect=1" /var/lib/selinux/targeted/active/booleans.local'

task 3 "The storage role's variable for a logical volume's size"
need "the answer is in /root/lab-answers/3" '[ -s /root/lab-answers/3 ]'
need "that's the right variable" 'answer 3 | grep -Eq "(^|[.[:space:]])size$"'
rm -f "$OUT"
