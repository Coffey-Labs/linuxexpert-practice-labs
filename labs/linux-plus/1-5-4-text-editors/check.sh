task 1 "vimtutor lessons 1 and 2" self

task 2 "/tmp/s.conf: the Port line copied and changed to Port 2222, nothing else"
need "/tmp/s.conf exists" '[ -f /tmp/s.conf ]'
need "/tmp/s.conf has the line Port 2222" 'grep -qx "Port 2222" /tmp/s.conf'
need "the only change from sshd_config is the new Port 2222 line" '
	[ "$(diff /etc/ssh/sshd_config /tmp/s.conf | grep "^[<>]")" = "> Port 2222" ]'
need "the new line is right below a line with Port" '
	grep -B1 -x "Port 2222" /tmp/s.conf | head -n1 | grep -q Port'

task 3 "A change in nano, quit without saving" self

task 4 "A preferred editor set for good"
need "EDITOR or VISUAL is set in a startup file, or select-editor was used" '
	grep -Eqs "^[[:space:]]*(export[[:space:]]+)?(EDITOR|VISUAL)=" /etc/environment /etc/profile.d/*.sh /root/.bashrc /root/.bash_profile /root/.profile /home/*/.bashrc /home/*/.bash_profile /home/*/.profile ||
	ls /root/.selected_editor /home/*/.selected_editor >/dev/null 2>&1'
