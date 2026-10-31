findmnt -n /mnt/projects >/dev/null 2>&1 && { umount /mnt/projects 2>/dev/null || umount -l /mnt/projects; }
awk '/^[[:space:]]*#/ || NF < 2 { print; next } $2 == "/mnt/projects" || $2 == "/mnt/projects/" { next } { print }' /etc/fstab >/etc/fstab.le-lab &&
	cat /etc/fstab.le-lab >/etc/fstab
rm -f /etc/fstab.le-lab
sed -i '\#^[[:space:]]*/srv/projects[[:space:]]#d' /etc/exports 2>/dev/null
for f in /etc/exports.d/*.exports; do
	[ -f "$f" ] && sed -i '\#^[[:space:]]*/srv/projects[[:space:]]#d' "$f"
done
command -v exportfs >/dev/null && exportfs -ra 2>/dev/null
command -v smbpasswd >/dev/null && smbpasswd -x dana >/dev/null 2>&1
if [ -f "$LAB_STATE/smb.conf.orig" ]; then cp -a "$LAB_STATE/smb.conf.orig" /etc/samba/smb.conf; fi
for u in nfs-server smbd nmbd; do
	grep -qx "$u" "$LAB_STATE/enabled-before" 2>/dev/null && continue
	systemctl disable --now "$u" >/dev/null 2>&1
done
rm -rf /etc/systemd/system/nfs-server.service.d/le-lab.conf
rmdir /etc/systemd/system/nfs-server.service.d 2>/dev/null
systemctl daemon-reload
# The packages installed since the lab started, and only those.
if [ -s "$LAB_STATE/pkgs-before" ]; then
	new=$(dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }' | sort -u |
		comm -13 "$LAB_STATE/pkgs-before" - | grep -Ev '^linux-')
	if [ -n "$new" ]; then
		say "Removing the packages installed since the lab started..."
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $new >/dev/null 2>&1
	fi
fi
if [ -f "$LAB_STATE/ufw.tar" ]; then
	rm -rf /etc/ufw && tar -C /etc -xf "$LAB_STATE/ufw.tar"
	ufw reload >/dev/null
fi
rm -rf /srv/projects /srv/samba/docs
rmdir /srv/samba /mnt/projects 2>/dev/null
groupdel docs 2>/dev/null
true
