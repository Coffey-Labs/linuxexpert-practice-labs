systemctl disable --quiet le-lab-boot-note.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-boot-note.service
systemctl daemon-reload
grubby --info=ALL 2>/dev/null | grep -q audit_backlog_limit= &&
	grubby --update-kernel=ALL --remove-args=audit_backlog_limit=8192 >/dev/null 2>&1
sed -i -E '/^GRUB_CMDLINE_LINUX/ s/ ?audit_backlog_limit=8192//' /etc/default/grub
t=$(state_get timeout)
if [ -n "$t" ] && ! grep -qx "GRUB_TIMEOUT=$t" /etc/default/grub || [ -n "$(state_get remade)" ]; then
	sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=$t/" /etc/default/grub
	grub2-mkconfig -o /boot/grub2/grub.cfg >/dev/null 2>&1
fi
true
