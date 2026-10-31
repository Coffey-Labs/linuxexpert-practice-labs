cfg=/boot/grub/grub.cfg
# Effective settings: /etc/default/grub, then grub.d/*.cfg, as
# grub-mkconfig reads them.
setting() {
	(
		. /etc/default/grub >/dev/null 2>&1
		for f in /etc/default/grub.d/*.cfg; do [ -e "$f" ] && . "$f" >/dev/null 2>&1; done
		eval "printf '%s' \"\${$1:-}\""
	)
}
first_linux() { awk '$1 == "linux" {print; exit}' "$cfg"; }
kernels_rebuilt() {
	local k v n=0
	for k in /boot/vmlinuz-*; do
		[ -e "$k" ] || continue
		v=${k#/boot/vmlinuz-}
		[ "/boot/initrd.img-$v" -nt "$LAB_STATE/since" ] || return 1
		n=$((n + 1))
	done
	[ "$n" -gt 0 ]
}

task 1 "GRUB menu for 10 seconds, no quiet or splash"
need "the settings read by update-grub give GRUB_TIMEOUT_STYLE=menu" '[ "$(setting GRUB_TIMEOUT_STYLE)" = menu ] || [ -z "$(setting GRUB_TIMEOUT_STYLE)" ]'
need "the settings read by update-grub give GRUB_TIMEOUT=10" '[ "$(setting GRUB_TIMEOUT)" = 10 ]'
need "the settings have no quiet or splash on the command line" '! printf "%s %s" "$(setting GRUB_CMDLINE_LINUX_DEFAULT)" "$(setting GRUB_CMDLINE_LINUX)" | grep -Ewq "quiet|splash"'
need "grub.cfg shows the menu for 10 seconds (update-grub)" 'grep -Eq "^[[:space:]]*set timeout=10$" $cfg && ! grep -Eq "timeout_style=(hidden|countdown)" $cfg'
need "grub.cfg boots the default entry without quiet or splash" '[ -n "$(first_linux)" ] && ! first_linux | grep -Ewq "quiet|splash"'
need "this boot ran without quiet or splash (/proc/cmdline; reboot)" '! grep -Ewq "quiet|splash" /proc/cmdline'

task 2 "Boot into recovery mode and get a writable root shell" self
task 3 "Boot from grub rescue>, then repair GRUB for good" self

task 4 "The initramfs of every installed kernel rebuilt"
need "every /boot/initrd.img-VERSION is newer than the lab's start (update-initramfs)" kernels_rebuilt
