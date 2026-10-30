systemctl disable --quiet le-lab-selinux-mode.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-selinux-mode.service
systemctl daemon-reload

for s in nginx httpd; do systemctl disable --quiet --now "$s" 2>/dev/null; done
if command -v semanage >/dev/null; then
	semanage fcontext -l -C 2>/dev/null | awk '$1 ~ /^\/srv\/web/ {print $1}' | sort -u |
		while read -r spec; do semanage fcontext -d "$spec" 2>/dev/null; done
	semanage port -d -t ssh_port_t -p tcp 2222 2>/dev/null
fi
rm -rf /srv/web

# sshd back to port 22 only.
changed=''
for f in /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf; do
	[ -f "$f" ] && grep -Eq '^[[:space:]]*Port[[:space:]]+2222[[:space:]]*$' "$f" || continue
	sed -i -E '/^[[:space:]]*Port[[:space:]]+2222[[:space:]]*$/d' "$f"
	changed=1
done
if [ -n "$changed" ] && sshd -t; then systemctl restart sshd; fi

setsebool -P httpd_can_network_connect off 2>/dev/null
sed -i -E 's/^[[:space:]]*SELINUX=(permissive|disabled)[[:space:]]*$/SELINUX=enforcing/' /etc/selinux/config
setenforce 1 2>/dev/null
true
