case $(systemd-analyze cat-config systemd/journald.conf 2>/dev/null | sed -n 's/^[[:space:]]*Storage=//p' | tail -n1) in
'' | auto) ;;
*) refuse "journald's Storage= is set to something other than auto; set it back to auto (or remove the line), then start the lab again." ;;
esac
state_set boot-id "$(cat /proc/sys/kernel/random/boot_id)"
if [ -d /var/log/journal ]; then
	# Stop writing there, then move it aside; the journal stays in /run.
	journalctl --relinquish-var
	mv /var/log/journal "$LAB_STATE/journal-orig"
	state_set had-journal yes
else
	state_set had-journal no
fi
