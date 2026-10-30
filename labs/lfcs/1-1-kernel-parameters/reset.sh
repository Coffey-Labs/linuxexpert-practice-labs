systemctl disable --quiet --now le-lab-links.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-links.service
systemctl daemon-reload
ip link del lab0 2>/dev/null

# Settings the tasks add.
rm -f /etc/sysctl.d/90-lab.conf
for f in /etc/sysctl.conf /etc/sysctl.d/*.conf; do
	[ -f "$f" ] && grep -q lab0 "$f" && sed -i '/lab0/d' "$f"
done
sysctl -qw net.ipv4.ip_forward=0
sysctl -qw vm.swappiness="$(state_get swappiness || echo 60)" 2>/dev/null

for f in /etc/modprobe.d/*.conf /etc/modules-load.d/*.conf; do
	[ -f "$f" ] && grep -qw dummy "$f" || continue
	sed -i '/\bdummy\b/d' "$f"
	grep -q '[^[:space:]]' "$f" || rm -f "$f"
done
[ -f /etc/modules ] && sed -i '/^[[:space:]]*dummy[[:space:]]*$/d' /etc/modules
modprobe -r dummy 2>/dev/null

if is_rhel; then
	grubby --update-kernel=ALL --remove-args=audit=1 2>/dev/null
	sed -i 's/ *audit=1//' /etc/default/grub
else
	if grep -qs 'audit=1' /etc/default/grub /etc/default/grub.d/*.cfg; then
		sed -i 's/ *audit=1//' /etc/default/grub /etc/default/grub.d/*.cfg
		update-grub >/dev/null 2>&1
	fi
fi
true
