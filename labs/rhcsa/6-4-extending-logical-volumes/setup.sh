vgs vg_lab >/dev/null 2>&1 && refuse "volume group vg_lab already exists; remove it and start again"
for m in /data /logs; do
	findmnt -n "$m" >/dev/null && refuse "$m is already mounted; unmount it and start again"
done
disk_add 0 2G >/dev/null
disk_add 1 1G >/dev/null
vgcreate -q vg_lab /dev/loop40 >/dev/null
lvcreate -q -y -n lv_data -L 500M vg_lab >/dev/null
lvcreate -q -y -n lv_logs -L 300M vg_lab >/dev/null
mkfs.xfs -q /dev/vg_lab/lv_data
mkfs.ext4 -q /dev/vg_lab/lv_logs
mkdir -p /data /logs
cat >>/etc/fstab <<'X'
/dev/vg_lab/lv_data /data xfs defaults 0 0
/dev/vg_lab/lv_logs /logs ext4 defaults 0 2
X
systemctl daemon-reload
mount /data
mount /logs
echo 'Keep this file.' >/data/keep.txt
echo 'Keep this file too.' >/logs/keep.txt
state_set logs-df "$(df -BM --output=size /logs | tail -n1 | tr -dc 0-9)"
