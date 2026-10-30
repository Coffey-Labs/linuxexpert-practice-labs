command -v getenforce >/dev/null || refuse "SELinux tools aren't installed"
[ "$(getenforce)" = Enforcing ] || refuse "SELinux isn't enforcing; set SELINUX=enforcing in /etc/selinux/config, reboot, and start again"
grep -Eq '^[[:space:]]*SELINUX=enforcing' /etc/selinux/config || refuse "/etc/selinux/config doesn't set SELINUX=enforcing; set it and start again"
cat /proc/sys/kernel/random/boot_id >"$LAB_STATE/setup-boot"
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/watch.sh <<'X'
#!/bin/bash
# Notes each change of what snap prints, with the boot it happened in.
log=$1 prev=''
boot=$(cat /proc/sys/kernel/random/boot_id)
snap() { echo "$(getenforce) $(grep -E '^[[:space:]]*SELINUX=' /etc/selinux/config | tail -n1 | tr -d ' ')"; }
while :; do
	cur=$(snap)
	[ "$cur" = "$prev" ] || { printf '%s %s\n' "$boot" "$cur" >>"$log"; prev=$cur; }
	sleep 1
done
X
cat >/etc/systemd/system/le-lab-watch.service <<X
[Unit]
Description=LINUXexpert practice lab: note the SELinux mode

[Service]
ExecStart=/bin/bash /usr/local/lib/le-lab/watch.sh $LAB_STATE/watch.log
Restart=always

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-watch.service
