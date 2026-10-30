pkg_install lsof

# /mnt/spare: a 1 GiB logical volume.
d0=$(disk_add 0 1100M)
pvcreate -q "$d0" >/dev/null
vgcreate -q labvg "$d0" >/dev/null
lvcreate -q -y -L 1G -n spare labvg >/dev/null
mkfs.ext4 -q /dev/labvg/spare
# /mnt/small: few inodes.
d1=$(disk_add 1 64M)
mkfs.ext4 -q -N 2048 "$d1"
mkdir -p /mnt/spare /mnt/small
sed -i '/# le-lab 4-5$/d' /etc/fstab
echo "/dev/labvg/spare /mnt/spare ext4 defaults,nofail 0 2 # le-lab 4-5" >>/etc/fstab
echo "UUID=$(blkid -s UUID -o value "$d1") /mnt/small ext4 defaults,nofail 0 2 # le-lab 4-5" >>/etc/fstab
systemctl daemon-reload
mount /mnt/spare
mount /mnt/small

# Task 1: a few large files.
mkdir -p /mnt/spare/backups /mnt/spare/media /mnt/spare/home/alice /mnt/spare/logs
fallocate -l 140M /mnt/spare/backups/db-2026-10-01.tar
fallocate -l 140M /mnt/spare/backups/db-2026-10-15.tar
fallocate -l 200M /mnt/spare/media/install.iso
fallocate -l 60M /mnt/spare/home/alice/photos.tar
echo "remember the milk" >/mnt/spare/home/alice/notes.txt

# Task 2: a program holding a deleted 250 MiB log.
cat >/usr/local/bin/applog <<'X'
#!/bin/bash
# Appends to its log forever.
exec 3>>/mnt/spare/logs/app.log
while :; do
	echo "$(date +%T) working" >&3
	sleep 30
done
X
chmod 755 /usr/local/bin/applog
cat >/etc/systemd/system/applog.service <<'X'
[Unit]
Description=Lab application that writes a log
RequiresMountsFor=/mnt/spare

[Service]
ExecStart=/usr/local/bin/applog
X
fallocate -l 250M /mnt/spare/logs/app.log
systemctl daemon-reload
systemctl start applog.service
sleep 1
rm -f /mnt/spare/logs/app.log

# Task 3: a journal past 200 MB.
if [ ! -d /var/log/journal ]; then
	mkdir -p /var/log/journal
	systemd-tmpfiles --create --prefix /var/log/journal
	journalctl --flush
	state_set made-journal 1
fi
head -c 260M /dev/urandom | base64 -w 45000 | systemd-cat -t lab-filler
sleep 2

# Task 4: a few files to start with.
mkdir -p /mnt/small/docs /mnt/small/conf
for i in 1 2 3 4 5; do echo "doc $i" >/mnt/small/docs/doc$i.txt; done
for i in 1 2 3; do echo "setting$i=on" >/mnt/small/conf/app$i.conf; done

# Task 5: logs to rotate.
rm -f /etc/logrotate.d/myapp
mkdir -p /var/log/myapp
chmod 755 /var/log/myapp
for f in app worker; do
	for i in 1 2 3; do echo "$(date +%F) $f: line $i"; done >/var/log/myapp/$f.log
done
