pkg_install bzip2 acl
[ -f /var/log/messages ] || refuse "/var/log/messages doesn't exist; is rsyslog installed and running?"
user_add dana
user_add erik
echo "Notes dana shares with erik" >/home/dana/shared.txt
chown dana: /home/dana/shared.txt
chmod 600 /home/dana/shared.txt
setfacl -m u:erik:r /home/dana/shared.txt
rm -rf /root/etc-backup.tar.bz2 /tmp/restore /tmp/messages /tmp/messages.gz /root/home.tgz
