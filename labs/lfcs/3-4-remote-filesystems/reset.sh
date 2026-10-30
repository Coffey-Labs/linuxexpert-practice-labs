for m in /mnt/share /mnt/projects /mnt/iscsi; do
	findmnt -n "$m" >/dev/null 2>&1 && { umount "$m" 2>/dev/null || umount -l "$m"; }
done
awk '/^[[:space:]]*#/ || NF < 2 { print; next }
	$2 == "/mnt/share" || $2 == "/mnt/projects" || $2 == "/mnt/iscsi" { next }
	{ print }' /etc/fstab >/etc/fstab.le-lab && cat /etc/fstab.le-lab >/etc/fstab
rm -f /etc/fstab.le-lab
# iSCSI: log out, forget the target, and clear it from the target side.
if command -v iscsiadm >/dev/null; then
	iscsiadm -m node -p 10.99.0.1 --logout >/dev/null 2>&1
	iscsiadm -m node -p 10.99.0.1 -o delete >/dev/null 2>&1
	iscsiadm -m discoverydb -t sendtargets -p 10.99.0.1 -o delete >/dev/null 2>&1
fi
if command -v targetcli >/dev/null && targetcli ls / 2>/dev/null | grep -q /var/lib/le-lab/iscsi; then
	targetcli clearconfig confirm=True >/dev/null 2>&1
	targetcli saveconfig >/dev/null 2>&1
fi
# NFS: take the export out.
sed -i '\#^[[:space:]]*/srv/share[[:space:]]#d' /etc/exports 2>/dev/null
for f in /etc/exports.d/*.exports; do
	[ -f "$f" ] && sed -i '\#^[[:space:]]*/srv/share[[:space:]]#d' "$f"
done
command -v exportfs >/dev/null && exportfs -ra 2>/dev/null
# Samba: drop the [projects] share and alice's Samba password.
if [ -f /etc/samba/smb.conf ]; then
	awk '/^[[:space:]]*\[/ { skip = ($0 ~ /^[[:space:]]*\[projects\]/) } !skip' /etc/samba/smb.conf >/etc/samba/smb.conf.le-lab &&
		cat /etc/samba/smb.conf.le-lab >/etc/samba/smb.conf
	rm -f /etc/samba/smb.conf.le-lab
fi
command -v smbpasswd >/dev/null && smbpasswd -x alice >/dev/null 2>&1
command -v semanage >/dev/null && semanage fcontext -d '/srv/samba(/.*)?' >/dev/null 2>&1
# Turn off the servers the lab turned on.
for u in nfs-server smb smbd nmb nmbd target rtslib-fb-targetctl; do
	grep -qx "$u" "$LAB_STATE/enabled-before" 2>/dev/null && continue
	systemctl disable --now "$u" >/dev/null 2>&1
done
for u in nfs-server smb smbd target rtslib-fb-targetctl; do
	rm -rf "/etc/systemd/system/$u.service.d/le-lab.conf"
	rmdir "/etc/systemd/system/$u.service.d" 2>/dev/null
done
systemctl disable --now --quiet le-lab-iscsi-logout.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-iscsi-logout.service
systemctl daemon-reload
rm -rf /srv/share /srv/samba /var/lib/le-lab/iscsi /root/.smbcred
rmdir /mnt/share /mnt/projects /mnt/iscsi 2>/dev/null
true
