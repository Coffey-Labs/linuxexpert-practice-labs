# The mailbox and saved mail of a user.
boxes() { local h; h=$(getent passwd "$1" | cut -d: -f6); echo "/var/mail/$1 /var/spool/mail/$1 $h/mbox"; }
# alias_of NAME: what the MTA's alias maps give for NAME.
alias_of() {
	local m
	for m in $(postconf -h alias_maps 2>/dev/null | tr ',' ' '); do
		case $m in nis:* | *.mail.aliases) continue ;; esac
		postmap -q "$1" "$m" 2>/dev/null && return 0
	done
	return 1
}
FWD=/home/alice/.forward

task 1 "Postfix running for this machine only, and a mail command"
need "Postfix is installed" 'pkg_installed postfix'
need "Postfix is running" active postfix
need "Postfix starts at boot" enabled postfix
need "Postfix listens only on loopback" 'postconf -h inet_interfaces | grep -Eqx "localhost|loopback-only|127\.0\.0\.1(, *\[?::1\]?)?"'
need "a mail command is installed" 'command -v mail'

task 2 "alice mailed herself Hello me"
need "alice has a message with the subject Hello me" 'grep -qs "^Subject: Hello me" $(boxes alice)'

task 3 "root's mail goes to alice"
need "/etc/aliases sends root to alice" 'grep -Eq "^root:[[:space:]]*.*\balice\b" /etc/aliases'
need "Postfix's alias database sends root to alice (newaliases)" 'alias_of root | grep -qw alice'
need "a message to root arrived in alice's mailbox" 'grep -Eqs "^X-Original-To: root(@|$)" $(boxes alice)'

task 4 "alice's .forward sends to bob and keeps a copy"
need "$FWD exists and is owned by alice" '[ "$(stat -c %U "$FWD")" = alice ]'
need "$FWD isn't writable by others" '! find "$FWD" -perm /022 | grep -q .'
need "$FWD sends to bob" 'grep -Eq "(^|[ ,])bob\b" "$FWD"'
need "$FWD keeps a copy for alice (\\alice)" 'grep -Fq "\\alice" "$FWD"'
need "bob received alice's forwarded mail" 'grep -Eqs "^X-Original-To: alice(@|$)" $(boxes bob)'

task 5 "The sendmail command's real program in /root/lab-answers/5"
need "the answer is the program /usr/sbin/sendmail really is" '[ -e /usr/sbin/sendmail ] && [ "$(answer 5)" = "$(readlink -f /usr/sbin/sendmail)" ]'
