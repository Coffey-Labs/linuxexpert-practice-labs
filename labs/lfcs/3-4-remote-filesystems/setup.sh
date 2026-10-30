peer_up
user_add alice
mkdir -p /srv/samba
echo 'Project notes' >/srv/samba/readme.txt
chown -R alice: /srv/samba
mkdir -p /var/lib/le-lab/iscsi
truncate -s 1G /var/lib/le-lab/iscsi/disk0.img
# Which servers were already on, so reset turns off only the lab's.
for u in nfs-server smb smbd nmb nmbd target rtslib-fb-targetctl; do
	enabled "$u" && printf '%s\n' "$u" >>"$LAB_STATE/enabled-before"
done
touch "$LAB_STATE/enabled-before"
# Servers and clients are one machine here: start the servers before
# network mounts are made, and stop them only after they're unmounted.
for u in nfs-server smb smbd target rtslib-fb-targetctl; do
	mkdir -p "/etc/systemd/system/$u.service.d"
	cat >"/etc/systemd/system/$u.service.d/le-lab.conf" <<'X'
[Unit]
Wants=remote-fs-pre.target
Before=remote-fs-pre.target
X
done
for u in target rtslib-fb-targetctl; do
	printf 'Before=iscsi.service open-iscsi.service iscsi-shutdown.service\n' >>"/etc/systemd/system/$u.service.d/le-lab.conf"
done
# At shutdown, log out of the lab's iSCSI target after its filesystems are
# unmounted and before the target stops.
cat >/etc/systemd/system/le-lab-iscsi-logout.service <<'X'
[Unit]
Description=LINUXexpert practice lab iSCSI logout at shutdown
Wants=remote-fs-pre.target
Before=remote-fs-pre.target
After=target.service rtslib-fb-targetctl.service iscsid.service iscsid.socket

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/true
ExecStop=-/bin/sh -c 'command -v iscsiadm >/dev/null && iscsiadm -m node -p 10.99.0.1 --logout'

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-iscsi-logout.service
