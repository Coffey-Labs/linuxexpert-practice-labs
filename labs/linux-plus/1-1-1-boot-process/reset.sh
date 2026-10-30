if is_rhel; then
	if [ -n "$(state_get added-quiet)" ]; then
		grubby --update-kernel=ALL --remove-args=quiet 2>/dev/null
	elif [ -d "$LAB_STATE" ]; then
		grubby --update-kernel=ALL --args=quiet 2>/dev/null
	fi
elif [ -f "$LAB_STATE/grub.tar" ]; then
	rm -rf /etc/default/grub.d
	tar -C /etc/default -xf "$LAB_STATE/grub.tar"
	update-grub >/dev/null 2>&1
fi
true
