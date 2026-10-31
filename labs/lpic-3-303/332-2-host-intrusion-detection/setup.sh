for p in /root/aide /root/oscap-results.xml; do
	[ -e $p ] && refuse "$p already exists; move it away and start again"
done
ls /etc/cron.d/ 2>/dev/null | grep -q aide && refuse "/etc/cron.d already has an AIDE job; remove it and start again"
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
ls /etc/audit/rules.d >"$LAB_STATE/rules-d" 2>/dev/null || true

# The changed file for task 2.
files=(/etc/logrotate.conf /etc/sudo.conf /etc/ssh/ssh_config)
f=${files[RANDOM % 3]}
[ -f "$f" ] || f=/etc/logrotate.conf
cp -a "$f" "$LAB_STATE/changed.orig"
state_set changed "$f"
printf '# changed for the practice lab\n' >>"$f"
true
