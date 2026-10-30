for u in svcbak carol; do
	id "$u" >/dev/null 2>&1 && refuse "user $u already exists; remove it and start again"
done
getent passwd 2001 >/dev/null && refuse "UID 2001 is already in use"
getent group 2001 >/dev/null && refuse "GID 2001 is already in use"
for d in /home/svcbak /home/carol /home/carol2; do
	[ -e "$d" ] && refuse "$d already exists; remove it and start again"
done
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/watch.sh <<'X'
#!/bin/bash
# Notes each change of what snap prints.
log=$1 prev=''
snap() {
	echo "$(grep -E '^(svcbak|carol):' /etc/passwd | tr '\n' '|') carol2=$(ls -A /home/carol2 2>/dev/null | tr '\n' ,)"
}
while :; do
	cur=$(snap)
	[ "$cur" = "$prev" ] || { printf '%s\n' "$cur" >>"$log"; prev=$cur; }
	sleep 1
done
X
cat >/etc/systemd/system/le-lab-watch.service <<X
[Unit]
Description=LINUXexpert practice lab: note the lab users

[Service]
ExecStart=/bin/bash /usr/local/lib/le-lab/watch.sh $LAB_STATE/watch.log
Restart=always

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-watch.service
