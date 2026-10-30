SINCE=$(state_get since)
# ports_line PORT NAMES-REGEX: a line of answer 2 has PORT and one of NAMES.
ports_line() { grep -Ei "(^|[^0-9])$1([^0-9]|$)" /root/lab-answers/2 2>/dev/null | grep -Eiq "$2"; }

task 1 "Setuid and setgid lists before and after testbash, and testbash gone"
need "/root/lab-answers/1-before lists /usr/bin/passwd" 'grep -q "/usr/bin/passwd$" /root/lab-answers/1-before'
need "1-before doesn't list testbash" '! grep -q testbash /root/lab-answers/1-before'
need "/root/lab-answers/1-after lists /usr/local/bin/testbash" 'grep -q "/usr/local/bin/testbash$" /root/lab-answers/1-after'
need "/usr/local/bin/testbash is deleted" '[ ! -e /usr/local/bin/testbash ]'

task 2 "Open ports and their processes in /root/lab-answers/2"
need "the answer has 9999 and its process" 'ports_line 9999 backupd'
need "the answer has 22 and its process" 'ports_line 22 "sshd|systemd"'

task 3 "tess has a hard limit of 50 processes"
need "a limits file sets tess's hard nproc to 50" 'conf_has /etc/security/limits.conf /etc/security/limits.d "^[[:space:]]*tess[[:space:]]+(hard|-)[[:space:]]+nproc[[:space:]]+50([[:space:]]|$)"'
need "ulimit -Hu in a login shell of tess's is 50" '[ "$(as_user tess "ulimit -Hu" 2>/dev/null | tail -n1)" = 50 ]'

task 4 "tess may run systemctl restart labweb with sudo, and nothing else"
need "sudo rules are valid" visudo -c
need "tess may run systemctl restart labweb" 'sudo -n -l -U tess "$(command -v systemctl)" restart labweb'
need "tess may not run systemctl stop labweb" '! sudo -n -l -U tess "$(command -v systemctl)" stop labweb'
need "tess may not run systemctl restart sshd" '! sudo -n -l -U tess "$(command -v systemctl)" restart sshd'
need "tess may not run a shell" '! sudo -n -l -U tess /bin/bash'

task 5 "locky's password locked, and a failed login as locky logged"
need "passwd -S shows locky's password locked" 'passwd -S locky | awk "\$2 ~ /^L/ {ok=1} END {exit !ok}"'
need "a failed login as locky is in the journal or lastb" 'journalctl -q --no-pager --since "$SINCE" | grep -w locky | grep -Eiq "fail|denied|not allowed|invalid" || lastb 2>/dev/null | grep -qw locky'
