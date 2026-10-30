for g in sales market; do
	getent group "$g" >/dev/null && refuse "group $g already exists; remove it and start again"
done
for g in 3000 3001; do
	getent group "$g" >/dev/null && refuse "GID $g is already in use"
done
for g in projects support; do
	getent group "$g" >/dev/null || { groupadd "$g"; echo "$g" >>"$LAB_STATE/groups"; }
done
user_add alice -G projects
user_add bob -G support
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/watch.sh <<'X'
#!/bin/bash
# Notes each change of what snap prints.
log=$1 prev=''
snap() { grep -E '^(sales|market):' /etc/group | tr '\n' ' '; }
while :; do
	cur=$(snap)
	[ "$cur" = "$prev" ] || { printf '%s\n' "$cur" >>"$log"; prev=$cur; }
	sleep 1
done
X
cat >/etc/systemd/system/le-lab-watch.service <<X
[Unit]
Description=LINUXexpert practice lab: note the sales group

[Service]
ExecStart=/bin/bash /usr/local/lib/le-lab/watch.sh $LAB_STATE/watch.log
Restart=always

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-watch.service
