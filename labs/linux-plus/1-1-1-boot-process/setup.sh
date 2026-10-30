if is_rhel; then
	command -v grubby >/dev/null || refuse "grubby isn't installed; this lab needs it (dnf install grubby)"
	# Something for task 3 to remove: quiet on every kernel.
	if grubby --info=ALL | grep '^args=' | grep -Evq '[" ]quiet[" ]'; then
		grubby --update-kernel=ALL --args=quiet
		state_set added-quiet 1
	fi
else
	command -v update-grub >/dev/null || refuse "update-grub isn't installed; this lab needs GRUB"
	tar -C /etc/default -cf "$LAB_STATE/grub.tar" grub $(cd /etc/default && ls -d grub.d 2>/dev/null)
	# Task 3 adds loglevel=7, so it mustn't be there yet.
	if grep -qs 'loglevel=7' /etc/default/grub /etc/default/grub.d/*.cfg; then
		sed -i 's/ *loglevel=7//' /etc/default/grub /etc/default/grub.d/*.cfg
		update-grub >/dev/null 2>&1
	fi
fi
