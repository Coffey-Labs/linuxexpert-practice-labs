for p in /root/practice /root/practice.tar.gz /root/scripts /tmp/private.txt; do
	[ ! -e "$p" ] || refuse "$p already exists; move it away first"
done
id bob >/dev/null 2>&1 && refuse "user bob already exists; remove it first (userdel -r bob)"

pkg_installed nano && state_set had-nano 1
pkg_installed openssh-server && state_set had-sshd 1
# sshd's settings, which task 3 may change: reset puts them back.
if [ -f /etc/ssh/sshd_config ]; then
	files=ssh/sshd_config
	[ -d /etc/ssh/sshd_config.d ] && files="$files ssh/sshd_config.d"
	tar -C /etc -cf "$LAB_STATE/sshd.tar" $files
	find /etc/ssh/sshd_config /etc/ssh/sshd_config.d -type f -exec sha256sum {} + 2>/dev/null | sort >"$LAB_STATE/sshd.sums" || true
fi
if [ -f /root/.bashrc ]; then cp -a /root/.bashrc "$LAB_STATE/bashrc"; fi
printf 'This line is for vi: before\nThis line is for nano: before\n' >/root/editme.txt

# Where the SSH log stands now, so check counts only new failures.
state_set start "$(date +%s)"
for f in /var/log/secure /var/log/auth.log; do
	[ -f "$f" ] && state_set "failed-${f##*/}" "$(grep -c 'Failed password' "$f")"
done
true
