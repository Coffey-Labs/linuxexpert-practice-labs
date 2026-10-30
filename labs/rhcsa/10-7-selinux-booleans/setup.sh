command -v getenforce >/dev/null && [ "$(getenforce)" = Enforcing ] || refuse "SELinux isn't enforcing; set SELINUX=enforcing in /etc/selinux/config, reboot, and start again"
pkg_installed policycoreutils-python-utils || pkg_install policycoreutils-python-utils
setsebool -P httpd_can_network_connect=off httpd_enable_homedirs=off
cat /proc/sys/kernel/random/boot_id >"$LAB_STATE/setup-boot"
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/watch.sh <<'X'
#!/bin/bash
# Notes each change of what snap prints, with the boot it happened in.
log=$1 prev=''
boot=$(cat /proc/sys/kernel/random/boot_id)
snap() { getsebool httpd_enable_homedirs | awk '{print $3}'; }
while :; do
	cur=$(snap)
	[ "$cur" = "$prev" ] || { printf '%s %s\n' "$boot" "$cur" >>"$log"; prev=$cur; }
	sleep 1
done
X
cat >/etc/systemd/system/le-lab-watch.service <<X
[Unit]
Description=LINUXexpert practice lab: note httpd_enable_homedirs

[Service]
ExecStart=/bin/bash /usr/local/lib/le-lab/watch.sh $LAB_STATE/watch.log
Restart=always

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-watch.service
