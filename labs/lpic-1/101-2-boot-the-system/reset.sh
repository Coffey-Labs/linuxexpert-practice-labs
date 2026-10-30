journalctl --relinquish-var 2>/dev/null
if [ "$(state_get had-journal)" = yes ] && [ -d "$LAB_STATE/journal-orig" ]; then
	# Put the original journal back, keeping what was written since.
	mkdir -p /var/log/journal
	for m in "$LAB_STATE"/journal-orig/*/; do
		[ -d "$m" ] || continue
		id=$(basename "$m")
		mkdir -p "/var/log/journal/$id"
		for f in "$m"*; do
			t=/var/log/journal/$id/$(basename "$f")
			[ -e "$t" ] && t=/var/log/journal/$id/orig-$(basename "$f")
			mv "$f" "$t"
		done
	done
	rm -rf "$LAB_STATE/journal-orig"
	systemd-tmpfiles --create --prefix /var/log/journal 2>/dev/null
	journalctl --flush 2>/dev/null
elif [ "$(state_get had-journal)" = no ]; then
	rm -rf /var/log/journal
fi
true
