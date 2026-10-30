IF=$(ip -4 route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
[ -n "$IF" ] || refuse "no default route; this lab needs a working network"
pkg_installed firewalld || pkg_install firewalld
systemctl is-active --quiet firewalld && state_set firewalld-was-active 1
enabled firewalld && state_set firewalld-was-enabled 1
tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
systemctl enable --now --quiet firewalld
firewall-cmd -q --state
Z=$(firewall-cmd --get-zone-of-interface="$IF" 2>/dev/null || firewall-cmd --get-default-zone)
state_set zone "$Z"
# A fresh start: none of the tasks' services or ports.
for s in http https ftp; do
	firewall-cmd -q --permanent --zone="$Z" --query-service=$s && firewall-cmd -q --permanent --zone="$Z" --remove-service=$s
done
firewall-cmd -q --permanent --zone="$Z" --query-port=8080/tcp && firewall-cmd -q --permanent --zone="$Z" --remove-port=8080/tcp
firewall-cmd -q --reload
firewall-cmd --permanent --zone="$Z" --list-services | tr ' ' '\n' | sort >"$LAB_STATE/services-before"

# Note the zone's services and ports, runtime (R) and permanent (P).
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/watch.sh <<'X'
#!/bin/bash
# Notes each change of what snap prints.
log=$1 z=$2 prev=''
snap() {
	echo "R ports=$(firewall-cmd --zone="$z" --list-ports | tr ' ' ,) services=$(firewall-cmd --zone="$z" --list-services | tr ' ' ,)" \
		"P ports=$(firewall-cmd --permanent --zone="$z" --list-ports | tr ' ' ,) services=$(firewall-cmd --permanent --zone="$z" --list-services | tr ' ' ,)"
}
while :; do
	if systemctl is-active --quiet firewalld; then
		cur=$(snap 2>/dev/null)
		[ "$cur" = "$prev" ] || { printf '%s\n' "$cur" >>"$log"; prev=$cur; }
	fi
	sleep 2
done
X
cat >/etc/systemd/system/le-lab-watch.service <<X
[Unit]
Description=LINUXexpert practice lab: note firewalld's services and ports
After=firewalld.service

[Service]
ExecStart=/bin/bash /usr/local/lib/le-lab/watch.sh $LAB_STATE/watch.log $Z
Restart=always

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-watch.service
