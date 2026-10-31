listening 4433 tcp && refuse "something already listens on port 4433; stop it and start again"
[ -e /root/dns ] && refuse "/root/dns already exists; move it away and start again"
command -v openssl >/dev/null || pkg_install openssl
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
# BIND's and the firewall's configuration, for reset to put back.
for d in $(pick "etc/named.conf etc/named var/named" "etc/bind var/lib/bind var/cache/bind"); do
	[ -e /$d ] && printf '%s\n' "$d" >>"$LAB_STATE/saved"
done
[ -s "$LAB_STATE/saved" ] && tar -C / -cf "$LAB_STATE/bind.tar" $(cat "$LAB_STATE/saved")
enabled "$(pick named named)" && state_set named-enabled 1
if systemctl is-active --quiet firewalld; then
	tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
elif command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw
fi
peer_up
true
