if [ -f "$LAB_STATE/grub-config.tar" ]; then
	rm -rf /etc/default/grub.d
	if tar -tf "$LAB_STATE/grub-config.tar" | grep -q '^etc/grub.d/40_custom$'; then :; else
		# 40_custom didn't exist; nothing to restore over it.
		rm -f /etc/grub.d/40_custom
	fi
	tar -C / -xpf "$LAB_STATE/grub-config.tar"
	if is_rhel; then grub2-mkconfig -o /boot/grub2/grub.cfg >/dev/null 2>&1
	else update-grub >/dev/null 2>&1; fi
fi
true
