[ -e /data/web ] && refuse "/data/web already exists; task 1 creates it. Remove it and start the lab again."
[ -e /data ] && state_set had-data 1
rm -rf /root/skel-backup /root/hosts-hard /root/hosts-soft
[ -f /etc/motd ] && cp -a /etc/motd "$LAB_STATE/motd"
sed -i '/^Authorized users only$/d' /etc/motd 2>/dev/null || true
