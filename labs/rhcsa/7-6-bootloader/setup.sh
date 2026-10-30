command -v grubby >/dev/null || refuse "grubby isn't installed; this lab needs a RHEL-style boot loader"
[ -f /boot/grub2/grub.cfg ] && [ -f /etc/default/grub ] || refuse "no /boot/grub2/grub.cfg or /etc/default/grub; this lab needs GRUB 2"
if grubby --info=ALL 2>/dev/null | grep -q audit_backlog_limit= || grep -q audit_backlog_limit= /etc/default/grub; then
	refuse "audit_backlog_limit is already set; remove it from the kernels and /etc/default/grub, and start again"
fi
cp -a /etc/default/grub "$LAB_STATE/default-grub"
t=$(sed -n 's/^GRUB_TIMEOUT=//p' /etc/default/grub | tr -d '"')
state_set timeout "$t"
cat /proc/sys/kernel/random/boot_id >"$LAB_STATE/setup-boot"
if [ "$t" = 10 ] || grep -m1 'set timeout=' /boot/grub2/grub.cfg | grep -q 'timeout=10$'; then
	# Already 10 seconds: start from 5.
	sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' /etc/default/grub
	grub2-mkconfig -o /boot/grub2/grub.cfg >/dev/null 2>&1
	state_set remade 1
fi
# Note the command line, and whether every kernel entry has the argument,
# at every boot.
cat >/etc/systemd/system/le-lab-boot-note.service <<X
[Unit]
Description=LINUXexpert practice lab: note the kernel command line at boot

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'a=no; grep -qw audit_backlog_limit=8192 /proc/cmdline && a=yes; e=all; grubby --info=ALL | grep "^args=" | grep -vqw audit_backlog_limit=8192 && e=some; echo "\$\$(cat /proc/sys/kernel/random/boot_id) cmdline=\$\$a entries=\$\$e" >>$LAB_STATE/boots'

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --quiet le-lab-boot-note.service
