rm -rf /data/web /root/skel-backup /root/hosts-hard /root/hosts-soft
[ -n "$(state_get had-data)" ] || rmdir /data 2>/dev/null
if [ -f "$LAB_STATE/motd" ]; then
	cp "$LAB_STATE/motd" /etc/motd
	restorecon /etc/motd 2>/dev/null
else
	sed -i '/^Authorized users only$/d' /etc/motd 2>/dev/null
fi
true
