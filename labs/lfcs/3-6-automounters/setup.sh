nfs_was_enabled=no
enabled nfs-server && nfs_was_enabled=yes
pkg_install nfs-utils/nfs-kernel-server
# The NFS server runs in the peer, not on the VM itself (Debian and Ubuntu
# start one when the package is installed).
[ "$nfs_was_enabled" = yes ] || systemctl disable --now nfs-server >/dev/null 2>&1 || true
enabled autofs && state_set autofs-enabled yes
peer_up
hosts_add "$LE_PEER_ADDR nfs1.lab.example nfs1"

user_add alice
user_add bob
mkdir -p /srv/share /export/home/alice /export/home/bob
echo 'Hello from nfs1' >/srv/share/hello.txt
for u in alice bob; do
	echo "Welcome home, $u" >"/export/home/$u/welcome.txt"
	chown -R "$u:" "/export/home/$u"
	chmod 700 "/export/home/$u"
done
mkdir -p /etc/exports.d
cat >/etc/exports.d/le-lab.exports <<X
/srv/share   10.99.0.0/24(rw,sync,no_subtree_check)
/export/home 10.99.0.0/24(rw,sync,no_subtree_check)
X

# The server: nfsd, mountd and rpcbind in the peer's network namespace,
# with private mounts so they don't meet the VM's own.
cat >"$LAB_STATE/nfs1.sh" <<'X'
set -e
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
mount -t tmpfs -o mode=755 tmpfs /run
mkdir -p /run/rpc_pipefs /run/rpcbind
if command -v restorecon >/dev/null; then restorecon -R /run; fi
rpcbind -w
mount -t nfsd nfsd /proc/fs/nfsd
mount -t rpc_pipefs sunrpc /run/rpc_pipefs
if command -v nfsdcld >/dev/null; then
	mkdir -p "$1/nfs1-cld"
	nfsdcld -p /run/rpc_pipefs -s "$1/nfs1-cld"
fi
echo 10 >/proc/fs/nfsd/nfsv4gracetime
echo 10 >/proc/fs/nfsd/nfsv4leasetime
exportfs -r
rpc.nfsd -H 10.99.0.2 8
exec rpc.mountd -F
X
cat >"$LAB_STATE/nfs1-stop.sh" <<'X'
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
mount -t nfsd nfsd /proc/fs/nfsd && echo 0 >/proc/fs/nfsd/threads
true
X
cat >/etc/systemd/system/le-lab-nfs1.service <<X
[Unit]
Description=LINUXexpert practice lab NFS server nfs1
After=le-lab-peer.service
Requires=le-lab-peer.service
# Start before network mounts and autofs, stop after them.
Wants=remote-fs-pre.target
Before=remote-fs-pre.target autofs.service

[Service]
NetworkNamespacePath=/run/netns/$LE_PEER_NS
PrivateMounts=yes
ExecStart=/bin/bash $LAB_STATE/nfs1.sh $LAB_STATE
ExecStopPost=/bin/bash $LAB_STATE/nfs1-stop.sh

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-nfs1.service

disk_add 0 256M >/dev/null
mkfs.ext4 -q -L lab /dev/loop40
