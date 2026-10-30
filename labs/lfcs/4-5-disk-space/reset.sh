systemctl stop applog.service 2>/dev/null
rm -f /etc/systemd/system/applog.service /usr/local/bin/applog
umount -l /mnt/spare /mnt/small 2>/dev/null
sed -i '/# le-lab 4-5$/d' /etc/fstab
systemctl daemon-reload
rmdir /mnt/spare /mnt/small 2>/dev/null
rm -rf /etc/logrotate.d/myapp /var/log/myapp
grep -lsE '^[[:space:]]*SystemMaxUse=' /etc/systemd/journald.conf.d/*.conf | xargs -r rm -f
rmdir /etc/systemd/journald.conf.d 2>/dev/null
sed -i 's/^[[:space:]]*SystemMaxUse=/#&/' /etc/systemd/journald.conf
if [ -n "$(state_get made-journal)" ]; then
	rm -rf /var/log/journal
fi
systemctl restart systemd-journald
true
