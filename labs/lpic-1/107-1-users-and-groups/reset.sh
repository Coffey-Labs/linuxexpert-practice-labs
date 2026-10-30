for u in dana appsvc; do
	pkill -KILL -u "$u" 2>/dev/null
	userdel -r "$u" 2>/dev/null
done
groupdel developers 2>/dev/null
users_remove
rm -rf /home/ken /home/lou /var/spool/mail/ken /var/spool/mail/lou /var/mail/ken /var/mail/lou
rm -f /var/tmp/ken-report.txt
for g in ken lou; do getent group "$g" >/dev/null && [ -z "$(getent group "$g" | cut -d: -f4)" ] && groupdel "$g" 2>/dev/null; done
[ -n "$(state_get made-testers)" ] && groupdel testers 2>/dev/null
true
