SETUP_BOOT=$(state_get setup-boot)
added() { awk -v b="$SETUP_BOOT" '$1 != b && $2 == "cmdline=yes" && $3 == "entries=all" {f = 1} END {exit !f}' "$LAB_STATE/boots" 2>/dev/null; }

task 1 "audit_backlog_limit=8192 on every kernel, and in use after a reboot"
need "a boot since the lab started ran with audit_backlog_limit=8192, with every kernel entry having it" added

task 2 "audit_backlog_limit=8192 removed again"
need "it was added first (task 1)" added
need "no kernel entry has it (grubby --info=ALL)" '! grubby --info=ALL 2>/dev/null | grep -q audit_backlog_limit='
need "/etc/default/grub doesn't have it" '! grep -q audit_backlog_limit= /etc/default/grub'

task 3 "GRUB menu timeout 10 seconds"
need "GRUB_TIMEOUT is 10 in /etc/default/grub" 'grep -Eq "^GRUB_TIMEOUT=\"?10\"?$" /etc/default/grub'
need "grub.cfg has set timeout=10 (grub2-mkconfig)" 'grep -m1 "set timeout=" /boot/grub2/grub.cfg | grep -q "set timeout=10$"'
