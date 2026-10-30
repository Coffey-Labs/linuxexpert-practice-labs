for m in /mnt/lab /mnt/inodes /mnt/scratch; do
	findmnt $m >/dev/null && refuse "something is mounted on $m; unmount it and start again"
	findmnt --fstab $m >/dev/null && refuse "/etc/fstab already has a line for $m; remove it and start again"
done
cp -a /etc/fstab "$LAB_STATE/fstab.orig"
d0=$(disk_add 0 256M); d1=$(disk_add 1 64M); d2=$(disk_add 2 256M)
mkfs.ext4 -q -F $d0
mkfs.ext4 -q -F -N 2048 $d1
mkfs.ext4 -q -F $d2
mkdir -p /mnt/lab /mnt/inodes /mnt/scratch
# Task 1: a UUID that doesn't exist.
echo 'UUID=00000000-0000-0000-0000-000000000000 /mnt/lab ext4 defaults,nofail 0 0' >>/etc/fstab
echo "UUID=$(blkid -s UUID -o value $d1) /mnt/inodes ext4 defaults,nofail 0 0" >>/etc/fstab
echo "UUID=$(blkid -s UUID -o value $d2) /mnt/scratch ext4 defaults,nofail 0 0" >>/etc/fstab
systemctl daemon-reload
mount /mnt/inodes; mount /mnt/scratch
[ "$(findmnt -n -o SOURCE /mnt/inodes)" = $d1 ] && [ "$(findmnt -n -o SOURCE /mnt/scratch)" = $d2 ] ||
	die "the spare disks didn't mount; run le-lab reset"
# Task 2: a cache that uses up every inode.
mkdir -p /mnt/inodes/data /mnt/inodes/cache
echo 'Customer data' >/mnt/inodes/data/records.txt
( cd /mnt/inodes/cache && i=0; while [ $i -lt 5000 ] && touch "c$i" 2>/dev/null; do i=$((i + 1)); done ) || true
# Task 3: a service that holds a deleted 200 MiB file open.
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/reportd.py <<'Y'
# Writes a big cache file, deletes it but keeps it open, and waits.
import os, time
open("/proc/self/comm", "w").write("reportd")
p = "/mnt/scratch/report-cache.bin"
f = open(p, "wb")
for _ in range(200):
    f.write(b"\0" * 1048576)
f.flush()
os.unlink(p)
while True:
    time.sleep(3600)
Y
cat >/etc/systemd/system/report-cache.service <<'Y'
[Unit]
Description=Report cache
RequiresMountsFor=/mnt/scratch

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/reportd.py
Y
systemctl daemon-reload
systemctl start report-cache.service
sleep 3
true
