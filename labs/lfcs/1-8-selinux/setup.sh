pkg_installed policycoreutils-python-utils || pkg_install policycoreutils-python-utils
[ "$(getenforce)" = Enforcing ] || die "SELinux isn't enforcing; set SELINUX=enforcing in /etc/selinux/config, reboot, and start again"

# Note the SELinux mode at every boot (task 5).
mkdir -p "$LAB_STATE"
cat >/etc/systemd/system/le-lab-selinux-mode.service <<X
[Unit]
Description=LINUXexpert practice lab: note the SELinux mode at boot

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo "\$\$(cat /proc/sys/kernel/random/boot_id) \$\$(getenforce)" >>$LAB_STATE/boot-modes'

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --quiet le-lab-selinux-mode.service

# The boolean starts off (task 4).
setsebool -P httpd_can_network_connect off
