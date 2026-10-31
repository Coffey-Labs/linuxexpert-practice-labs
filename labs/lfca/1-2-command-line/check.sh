A=/root/lab-answers
# A wrong SSH password since the lab started, in the journal or the log files.
failed_logged() {
	journalctl --since "@$(state_get start)" 2>/dev/null | grep -q "Failed password" && return 0
	local f
	for f in /var/log/secure /var/log/auth.log; do
		[ -f "$f" ] || continue
		[ "$(grep -c 'Failed password' "$f")" -gt "$(state_get "failed-${f##*/}" || echo 0)" ] && return 0
	done
	return 1
}
new_shell() { env -i HOME=/root TERM=dumb PATH=/usr/sbin:/usr/bin:/sbin:/bin bash -ic "$1" 2>/dev/null; }

task 1 "~/practice/a/b made"
need "/root/practice/a/b is a directory" '[ -d /root/practice/a/b ]'

task 2 "The .conf files under /etc listed in ~/conf-files.txt and counted"
need "/root/conf-files.txt lists files under /etc ending in .conf" '[ "$(grep -c "^/etc/.*\.conf$" /root/conf-files.txt)" -gt 20 ] && ! grep -v "\.conf$" /root/conf-files.txt | grep -q .'
need "it lists most of them" '[ $(( $(wc -l </root/conf-files.txt) * 10 )) -ge $(( $(find /etc -name "*.conf" | wc -l) * 9 )) ]'
need "/root/lab-answers/2 has its line count" '[ "$(answer 2)" = "$(wc -l </root/conf-files.txt)" ]'

task 3 "A failed SSH password logged and counted"
need "sshd logged a wrong password since the lab started" failed_logged
need "/root/lab-answers/3 has the count, a number above 0" '[[ "$(answer 3)" =~ ^[0-9]+$ ]] && [ "$(answer 3)" -gt 0 ]'

task 4 "/tmp/private.txt only for you; bob can't read it"
need "/tmp/private.txt exists" '[ -f /tmp/private.txt ]'
need "its permissions are rw------- (600)" '[ "$(stat -c %a /tmp/private.txt)" = 600 ]'
need "user bob exists, with a home directory" 'id bob && [ -d "$(getent passwd bob | cut -d: -f6)" ]'
need "bob can't read it" '! runuser -u bob -- cat /tmp/private.txt'

task 5 "~/practice archived to ~/practice.tar.gz and restored"
need "/root/practice.tar.gz is a gzip-compressed tar archive" 'tar -tzf /root/practice.tar.gz'
need "the archive has practice/a/b" 'tar -tzf /root/practice.tar.gz | grep -Eq "(^|/)practice/a/b/?$"'
need "/root/practice/a/b is back" '[ -d /root/practice/a/b ]'

task 6 "~/editme.txt edited in vi and nano"
need "the first line says after" '[ "$(sed -n 1p /root/editme.txt)" = "This line is for vi: after" ]'
need "the second line says after" '[ "$(sed -n 2p /root/editme.txt)" = "This line is for nano: after" ]'
need "nano is installed" 'command -v nano'

task 7 "~/scripts on PATH from ~/.bashrc, with a script hello"
need "/root/scripts/hello starts with #!/bin/bash" '[ "$(head -n1 /root/scripts/hello)" = "#!/bin/bash" ]'
need "it's executable by its owner" '[ -x /root/scripts/hello ] && stat -c %A /root/scripts/hello | grep -q "^...x"'
need "~/.bashrc puts ~/scripts on PATH" 'grep -q "scripts" /root/.bashrc && grep "scripts" /root/.bashrc | grep -q PATH'
need "a new shell finds hello in ~/scripts" '[ "$(new_shell "type -P hello")" = /root/scripts/hello ]'
need "hello runs in a new shell" 'new_shell hello'
