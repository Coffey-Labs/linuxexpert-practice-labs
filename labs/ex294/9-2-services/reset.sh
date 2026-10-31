# The nodes go with nodes_down and greg (with his project) with
# users_remove. Here: this VM's units as setup found them, then what the
# tasks and setup installed.
rm -f /etc/sudoers.d/le-lab-greg
if [ ! -f "$LAB_STATE/had-hello" ] && [ -f /etc/systemd/system/hello.service ]; then
	systemctl disable --now --quiet hello.service 2>/dev/null
	rm -f /etc/systemd/system/hello.service
fi
for u in rpcbind.socket rpcbind chronyd; do
	s=$(state_get "unit-$u") || continue
	[ -n "$s" ] || continue
	systemctl unmask --quiet "$u" 2>/dev/null
	case $s in enabled*) systemctl enable --quiet "$u" 2>/dev/null ;; disabled*) systemctl disable --quiet "$u" 2>/dev/null ;; esac
	case $s in *" active") systemctl start "$u" 2>/dev/null ;; esac
done
t=$(state_get default-target)
[ -z "$t" ] || [ "$(systemctl get-default)" = "$t" ] || systemctl set-default --quiet "$t" 2>/dev/null
systemctl daemon-reload
if [ -f "$LAB_STATE/rpms" ]; then
	new=$(comm -13 "$LAB_STATE/rpms" <(rpm -qa --qf '%{NAME}\n' | sort -u))
	[ -z "$new" ] || dnf -y -q remove $new >/dev/null 2>&1
fi
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
true
