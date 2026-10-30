pkg_installed httpd && state_set httpd-before 1
cat /proc/sys/kernel/random/boot_id >"$LAB_STATE/setup-boot"
# Note httpd's state every second, and at every boot.
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/watch.sh <<'X'
#!/bin/bash
# Notes each change of what snap prints, with the boot it happened in.
log=$1 prev=''
boot=$(cat /proc/sys/kernel/random/boot_id)
snap() { echo "$(systemctl is-enabled httpd 2>/dev/null || true) $(systemctl is-active httpd 2>/dev/null || true)"; }
while :; do
	cur=$(snap)
	[ "$cur" = "$prev" ] || { printf '%s %s\n' "$boot" "$cur" >>"$log"; prev=$cur; }
	sleep 1
done
X
cat >/etc/systemd/system/le-lab-watch.service <<X
[Unit]
Description=LINUXexpert practice lab: note httpd's state

[Service]
ExecStart=/bin/bash /usr/local/lib/le-lab/watch.sh $LAB_STATE/watch.log
Restart=always

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-watch.service
