for p in /srv/projects /srv/samba/docs /mnt/projects; do
	[ -e "$p" ] && refuse "$p already exists; move it away and start again"
done
getent group docs >/dev/null && refuse "a group docs already exists; remove it and start again"
# Reset removes the packages installed from here on, and only those.
dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }' | sort -u >"$LAB_STATE/pkgs-before"
for u in nfs-server smbd nmbd; do
	enabled "$u" && printf '%s\n' "$u" >>"$LAB_STATE/enabled-before"
done
touch "$LAB_STATE/enabled-before"
[ -f /etc/samba/smb.conf ] && cp -a /etc/samba/smb.conf "$LAB_STATE/smb.conf.orig"
if command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw
fi
pkg_installed smbclient || pkg_install smbclient
peer_up
groupadd docs
user_add pat
user_add dana -G docs
user_add eli
# The server and client are one machine for NFS: start the server before
# network mounts are made, and stop it only after they're unmounted.
mkdir -p /etc/systemd/system/nfs-server.service.d
cat >/etc/systemd/system/nfs-server.service.d/le-lab.conf <<'X'
[Unit]
Wants=remote-fs-pre.target
Before=remote-fs-pre.target
X
systemctl daemon-reload
