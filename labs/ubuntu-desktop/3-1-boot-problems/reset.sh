# GRUB's files back where task 3 found them.
[ ! -e /boot/grub ] && [ -d /boot/grub.bak ] && mv /boot/grub.bak /boot/grub
rm -f /root/recovery-test
if [ -f "$LAB_STATE/default/grub" ]; then
	changed=
	cmp -s "$LAB_STATE/default/grub" /etc/default/grub || changed=1
	if [ -d "$LAB_STATE/default/grub.d" ]; then
		diff -r "$LAB_STATE/default/grub.d" /etc/default/grub.d >/dev/null 2>&1 || changed=1
	elif [ -e /etc/default/grub.d ]; then
		changed=1
	fi
	if [ -n "$changed" ]; then
		cp -a "$LAB_STATE/default/grub" /etc/default/grub
		rm -rf /etc/default/grub.d
		[ -d "$LAB_STATE/default/grub.d" ] && cp -a "$LAB_STATE/default/grub.d" /etc/default/grub.d
		update-grub >/dev/null 2>&1
	fi
fi
true
