AR=$(auditctl -l 2>/dev/null)
# ev KEY [ausearch options]: a syscall event with this key is logged.
ev() { local k=$1; shift; ausearch --input-logs -m SYSCALL -k "$k" "$@" </dev/null 2>/dev/null | grep -q "type=SYSCALL"; }
# rule_result RULE: the result oscap saved for a rule.
rule_result() {
	python3 -c '
import sys, xml.etree.ElementTree as ET
for e in ET.parse("/root/oscap-results.xml").iter():
    if e.tag.endswith("}rule-result") and e.get("idref", "").endswith("_rule_" + sys.argv[1]):
        for r in e:
            if r.tag.endswith("}result"): print(r.text)' "$1" 2>/dev/null
}

task 1 "Permanent audit rules hosts-change and access-denied; events found"
need "auditd is running and enabled" 'active auditd && enabled auditd'
need "the watch on /etc/hosts (wa, key hosts-change) is loaded" 'grep -Eq "^-w /etc/hosts -p (wa|aw) -k hosts-change$" <<<"$AR"'
need "the access-denied rule is loaded" 'grep -- "-S openat" <<<"$AR" | grep -- "exit=-EACCES" | grep -- "auid>=1000" | grep -q "key=access-denied"'
need "both rules are in /etc/audit/rules.d" 'cat /etc/audit/rules.d/*.rules 2>/dev/null >/tmp/le-rules; grep -Eq "^-w /etc/hosts .*hosts-change" /tmp/le-rules && grep -q "access-denied" /tmp/le-rules'
need "a change to /etc/hosts was logged" 'ev hosts-change -f /etc/hosts'
need "a login user's denied read of /etc/shadow was logged" 'ev access-denied -f /etc/shadow'
rm -f /tmp/le-rules

task 2 "The changed packaged file, in /root/lab-answers/2"
need "/root/lab-answers/2 names the file the lab changed" '[ "$(answer 2)" = "$(state_get changed)" ]'

task 3 "AIDE database /root/aide/aide.db for /etc/ssh and /usr/sbin"
need "/root/aide/lab.conf passes aide --config-check" 'aide --config-check -c /root/aide/lab.conf'
need "it reads /root/aide/aide.db and writes /root/aide/aide.db.new" 'grep -Eq "^[[:space:]]*database_in[[:space:]]*=[[:space:]]*file:/root/aide/aide\.db[[:space:]]*$" /root/aide/lab.conf && grep -Eq "^[[:space:]]*database_out[[:space:]]*=[[:space:]]*file:/root/aide/aide\.db\.new[[:space:]]*$" /root/aide/lab.conf'
need "/root/aide/aide.db is an uncompressed AIDE database" 'head -c 200 /root/aide/aide.db | grep -q "^@@begin_db"'
need "it has SHA-256 sums" 'grep -m1 "^@@db_spec" /root/aide/aide.db | grep -q sha256'
need "it covers /etc/ssh and /usr/sbin" 'grep -q "^/etc/ssh/ssh_config " /root/aide/aide.db && grep -q "^/usr/sbin/" /root/aide/aide.db'
need "it doesn't cover the rest of the system" '! grep -Eq "^/(bin|etc/passwd|var|home)[/ ]" /root/aide/aide.db'
need "aide --check -c /root/aide/lab.conf runs" 'aide --check -c /root/aide/lab.conf >/dev/null 2>&1; [ $? -lt 14 ]'
need "/usr/sbin has no file the lab check would call planted" '[ -z "$(find /usr/sbin -newer /root/aide/aide.db -type f 2>/dev/null)" ]'

task 4 "Nightly AIDE check at 3:30 from /etc/cron.d, mailed to root"
need "a file in /etc/cron.d runs aide --check -c /root/aide/lab.conf at 3:30 as root" 'grep -hEv "^[[:space:]]*#" /etc/cron.d/* 2>/dev/null | grep -E "aide.*--check.*-c[[:space:]]*/root/aide/lab\.conf|aide.*-c[[:space:]]*/root/aide/lab\.conf.*--check" | grep -Eq "^30[[:space:]]+0?3[[:space:]]+\*[[:space:]]+\*[[:space:]]+\*[[:space:]]+root[[:space:]]"'
need "it mails its output to root" 'grep -l "aide" /etc/cron.d/* 2>/dev/null | xargs grep -Eqs "^[[:space:]]*MAILTO=\"?root\"?"'

task 5 "OpenSCAP results for two CIS rules in /root/oscap-results.xml" rhel
need "/root/oscap-results.xml holds XCCDF results" 'grep -q "TestResult" /root/oscap-results.xml'
need "it has a result for package_aide_installed" 'rule_result package_aide_installed | grep -Eqx "pass|fail"'
need "it has a result for sshd_disable_root_login" 'rule_result sshd_disable_root_login | grep -Eqx "pass|fail"'

task 6 "chkrootkit, rkhunter (with a baseline) and debsums" debian
need "chkrootkit, rkhunter and debsums are installed" 'pkg_installed chkrootkit && pkg_installed rkhunter && pkg_installed debsums'
need "rkhunter has a baseline of file properties" 'grep -q "^File:" /var/lib/rkhunter/db/rkhunter.dat'
need "rkhunter has run its checks" 'grep -qs "Rootkit checks" /var/log/rkhunter.log'
