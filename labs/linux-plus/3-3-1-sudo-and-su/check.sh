START=$(state_get start)
F=/etc/sudoers.d/sudotest
L=$(sudo -l -U sudotest 2>/dev/null)

task 1 "sudotest may run only systemctl status of the SSH service"
need "user sudotest exists" 'id sudotest'
need "$F has mode 440" '[ "$(stat -c %a $F)" = 440 ]'
need "visudo -c finds no errors" 'visudo -c'
need "sudotest may run systemctl status sshd or ssh" 'sudo -l -U sudotest /usr/bin/systemctl status sshd || sudo -l -U sudotest /usr/bin/systemctl status ssh'
need "sudotest may not run id, or anything else" '! sudo -l -U sudotest /usr/bin/id && ! sudo -l -U sudotest /usr/bin/systemctl restart sshd && ! grep -Eq "\(ALL( : ALL)?\) (NOPASSWD: )?ALL$" <<<"$L"'

task 2 "The refused sudo id found in the journal"
need "the journal shows sudo refusing a command of sudotest" 'journalctl -q --no-pager _COMM=sudo --since "@$START" | grep -E "sudotest ?:" | grep -q "command not allowed"'

task 3 "less /etc/shadow allowed with NOEXEC"
need "sudotest may run /usr/bin/less /etc/shadow" 'sudo -l -U sudotest /usr/bin/less /etc/shadow'
need "the rule for less has NOEXEC" 'grep -Eq "NOEXEC: .*/usr/bin/less /etc/shadow" <<<"$L"'
need "the rule from task 1 is still there" 'sudo -l -U sudotest /usr/bin/systemctl status sshd || sudo -l -U sudotest /usr/bin/systemctl status ssh'
