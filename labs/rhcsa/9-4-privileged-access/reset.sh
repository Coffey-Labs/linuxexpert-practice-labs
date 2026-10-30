if [ -f "$LAB_STATE/sudoers.tar" ]; then
	rm -rf /etc/sudoers.d
	tar -C /etc -xf "$LAB_STATE/sudoers.tar"
fi
users_remove
[ -n "$(state_get made-devs)" ] && groupdel devs 2>/dev/null
true
