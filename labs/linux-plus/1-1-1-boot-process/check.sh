line() { sed -n "${1}p" /root/lab-answers/1 2>/dev/null | tr 'A-Z' 'a-z' | tr -d '[:space:]'; }
fw=bios; [ -d /sys/firmware/efi ] && fw=uefi

task 1 "UEFI or BIOS, and the default target, in /root/lab-answers/1"
need "the first line says ${fw^^}" '[ "$(line 1)" = "$fw" ]'
need "the second line is the default target, $(systemctl get-default)" '[ "$(line 2)" = "$(systemctl get-default)" ]'

task 2 "Boot once into rescue mode" self

if is_rhel; then
	task 3 "quiet removed from every kernel's command line" rhel
	need "no boot entry has quiet (grubby --info=ALL)" '[ -n "$(grubby --info=ALL | grep "^args=")" ] && ! grubby --info=ALL | grep "^args=" | grep -Eq "[\" ]quiet[\" ]"'
	need "the running kernel was booted without quiet (reboot)" '! grep -Eq "(^| )quiet( |$)" /proc/cmdline'
else
	task 3 "loglevel=7 added to GRUB_CMDLINE_LINUX_DEFAULT" debian
	need "GRUB_CMDLINE_LINUX_DEFAULT ends up with loglevel=7" '
		v=$(bash -c ". /etc/default/grub; for f in /etc/default/grub.d/*.cfg; do [ -f \"\$f\" ] && . \"\$f\"; done; printf %s \"\$GRUB_CMDLINE_LINUX_DEFAULT\"")
		grep -Eq "(^| )loglevel=7( |$)" <<<"$v"'
	need "/boot/grub/grub.cfg has loglevel=7 (update-grub)" 'awk "\$1 == \"linux\"" /boot/grub/grub.cfg | grep -Eq "[[:space:]]loglevel=7([[:space:]]|$)"'
	need "the running kernel was booted with loglevel=7 (reboot)" 'grep -Eq "(^| )loglevel=7( |$)" /proc/cmdline'
fi
