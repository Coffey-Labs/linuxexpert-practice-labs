installed_pkgs() { dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' 2>/dev/null | awk '$1 ~ /^.i/ {print $2}' | sort -u; }
[ -e /sys/class/net/lab0 ] && refuse "an interface lab0 already exists; remove it first"
if command -v nmcli >/dev/null; then
	systemctl is-active --quiet NetworkManager || refuse "NetworkManager is installed but not running; start it first"
	nmcli -g NAME connection show | grep -qx office && refuse "a NetworkManager profile office already exists; delete it first"
	nmcli -g connection.interface-name connection show 2>/dev/null | grep -qx lab0 && refuse "a NetworkManager profile for lab0 already exists; delete it first"
else
	# Ubuntu Server: NetworkManager ships with every wired interface
	# unmanaged unless netplan hands it over, so the connection stays
	# with systemd-networkd.
	installed_pkgs >"$LAB_STATE/pkgs-before"
	pkg_install network-manager
	comm -13 "$LAB_STATE/pkgs-before" <(installed_pkgs) >"$LAB_STATE/pkgs-added"
	systemctl enable --now --quiet NetworkManager
	for i in $(seq 20); do nmcli general >/dev/null 2>&1 && break; sleep 0.5; done
fi

cat >/etc/systemd/system/le-lab-lab0.service <<'UNIT'
[Unit]
Description=Spare interface lab0 for a LINUXexpert practice lab
Before=network-pre.target NetworkManager.service
Wants=network-pre.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c 'ip link show lab0 >/dev/null 2>&1 || ip link add lab0 type dummy'
ExecStop=/bin/sh -c 'ip link del lab0 2>/dev/null || true'

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now --quiet le-lab-lab0.service
