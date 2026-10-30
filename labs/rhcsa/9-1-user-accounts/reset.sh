systemctl disable --now --quiet le-lab-watch.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-watch.service /usr/local/lib/le-lab/watch.sh
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
for u in carol svcbak; do userdel -r "$u" >/dev/null 2>&1; done
rm -rf /home/svcbak /home/carol /home/carol2 /var/spool/mail/carol /var/spool/mail/svcbak
true
