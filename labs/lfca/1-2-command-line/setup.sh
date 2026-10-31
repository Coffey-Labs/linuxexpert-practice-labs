for p in /root/practice /root/practice.tar.gz /root/scripts /tmp/private.txt; do
	[ ! -e "$p" ] || refuse "$p already exists; move it away first"
done
id bob >/dev/null 2>&1 && refuse "user bob already exists; remove it first (userdel -r bob)"

pkg_installed nano && state_set had-nano 1
if [ -f /root/.bashrc ]; then cp -a /root/.bashrc "$LAB_STATE/bashrc"; fi
printf 'This line is for vi: before\nThis line is for nano: before\n' >/root/editme.txt

# Where the SSH log stands now, so check counts only new failures.
state_set start "$(date +%s)"
for f in /var/log/secure /var/log/auth.log; do
	[ -f "$f" ] && state_set "failed-${f##*/}" "$(grep -c 'Failed password' "$f")"
done
true
