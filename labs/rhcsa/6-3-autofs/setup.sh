for m in /shares /rhome /mnt/direct; do
	findmnt -n "$m" >/dev/null && refuse "$m is already mounted; unmount it and start again"
done
[ -e /exports ] && refuse "/exports already exists; the lab's server needs it"
nfs_was_enabled=no
enabled nfs-server && nfs_was_enabled=yes
pkg_installed nfs-utils || pkg_install nfs-utils
[ "$nfs_was_enabled" = yes ] || systemctl disable --now nfs-server >/dev/null 2>&1 || true
enabled autofs && state_set autofs-enabled yes
peer_up
hosts_add "$LE_PEER_ADDR server.lab.example server"

user_add alice
user_add bob
usermod -d /rhome/alice alice
mkdir -p /exports/share /exports/homes/alice /exports/homes/bob
echo 'This file is on the NFS server.' >/exports/share/readme.txt
for u in alice bob; do
	cp -a /etc/skel/. "/exports/homes/$u/"
	echo "Welcome home, $u" >"/exports/homes/$u/welcome.txt"
	chown -R "$u:" "/exports/homes/$u"
	chmod 700 "/exports/homes/$u"
done
mkdir -p /etc/exports.d
cat >/etc/exports.d/le-lab.exports <<X
/exports/share 10.99.0.0/24(rw,sync,no_subtree_check)
/exports/homes 10.99.0.0/24(rw,sync,no_subtree_check)
X

# The server: nfsd, mountd and rpcbind in the peer's network namespace,
# with private mounts so they don't meet the VM's own.
cat >"$LAB_STATE/server.sh" <<'X'
set -e
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
mount -t tmpfs -o mode=755 tmpfs /run
mkdir -p /run/rpc_pipefs /run/rpcbind
if command -v restorecon >/dev/null; then restorecon -R /run; fi
rpcbind -w
mount -t nfsd nfsd /proc/fs/nfsd
mount -t rpc_pipefs sunrpc /run/rpc_pipefs
if command -v nfsdcld >/dev/null; then
	mkdir -p "$1/server-cld"
	nfsdcld -p /run/rpc_pipefs -s "$1/server-cld"
fi
echo 10 >/proc/fs/nfsd/nfsv4gracetime
echo 10 >/proc/fs/nfsd/nfsv4leasetime
exportfs -r
rpc.nfsd -H 10.99.0.2 8
exec rpc.mountd -F
X
cat >"$LAB_STATE/server-stop.sh" <<'X'
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
mount -t nfsd nfsd /proc/fs/nfsd && echo 0 >/proc/fs/nfsd/threads
true
X
cat >/etc/systemd/system/le-lab-nfs-server.service <<X
[Unit]
Description=LINUXexpert practice lab NFS server
After=le-lab-peer.service
Requires=le-lab-peer.service
# Start before network mounts and autofs, stop after them.
Wants=remote-fs-pre.target
Before=remote-fs-pre.target autofs.service

[Service]
NetworkNamespacePath=/run/netns/$LE_PEER_NS
PrivateMounts=yes
ExecStart=/bin/bash $LAB_STATE/server.sh $LAB_STATE
ExecStopPost=/bin/bash $LAB_STATE/server-stop.sh

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-nfs-server.service
