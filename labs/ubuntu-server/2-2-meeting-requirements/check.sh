# The script: in the student's home, or root's.
script() {
	local h u
	u=$(state_get student)
	[ -n "$u" ] && h=$(getent passwd "$u" | cut -d: -f6) && [ -f "$h/check.sh" ] && { echo "$h/check.sh"; return; }
	[ -f /root/check.sh ] && { echo /root/check.sh; return; }
	for h in /home/*/check.sh; do [ -f "$h" ] && { echo "$h"; return; }; done
	return 1
}
out() { timeout 30 bash "$(script)" 2>/dev/null | grep -v '^[[:space:]]*$'; }
ok() { if eval "$1"; then echo PASS; else echo FAIL; fi; }
expected() {
	ok '[ "$(nproc)" -ge 2 ]'
	ok '[ "$(free -g | awk "/^Mem:/ { print \$2 }")" -ge 2 ]'
	ok '[ "$(df -BG --output=avail / | tail -n1 | tr -dc 0-9)" -ge 10 ]'
	ok '. /etc/os-release && [ "$ID" = ubuntu ] && [ "$VERSION_ID" = 24.04 ]'
}
results() { out | grep -Eo 'PASS|FAIL' ; }
kvm_truth() { if grep -Eqw 'vmx|svm' /proc/cpuinfo; then echo yes; else echo no; fi; }
# has_line PORT ADDRESS PROGRAM: a line of the answer has all three.
has_line() {
	awk -v p="$1" -v a="$2" -v n="$3" '
		{ l = tolower($0); hp = ha = hn = 0
		  for (i = 1; i <= NF; i++) if ($i == p || $i ~ (":" p "$")) hp = 1
		  if (index(l, a)) ha = 1
		  if (a == "0.0.0.0" && (l ~ /(^|[ :])\*([ :]|$)/ || l ~ /all|any|every/)) ha = 1
		  if (index(l, n)) hn = 1
		  if (hp && ha && hn) f = 1 }
		END { exit !f }' /root/lab-answers/3
}

task 1 "check.sh prints four PASS or FAIL lines that match the system"
need "check.sh is in your home directory" script
need "bash ~/check.sh prints four lines" '[ "$(out | wc -l)" -eq 4 ]'
need "each line says PASS or FAIL" '[ "$(results | wc -l)" -eq 4 ]'
need "the results match nproc, free -g, df and /etc/os-release, in that order" '[ "$(results)" = "$(expected)" ]'

task 2 "KVM support and virtualization found"
need "/root/lab-answers/2-kvm says yes or no, correctly" '[ "$(answer 2-kvm)" = "$(kvm_truth)" ]'
need "/root/lab-answers/2-virt matches systemd-detect-virt" '[ "$(answer 2-virt)" = "$(systemd-detect-virt 2>/dev/null)" ]'

task 3 "The listeners on ports 80 and 5432 found"
need "/root/lab-answers/3 gives port 80, its address 0.0.0.0, and the program" 'has_line 80 0.0.0.0 intranetd'
need "/root/lab-answers/3 gives port 5432, its address 127.0.0.1, and the program" 'has_line 5432 127.0.0.1 reportdb'
