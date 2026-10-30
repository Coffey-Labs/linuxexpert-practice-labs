for u in dana appsvc; do
	id "$u" >/dev/null 2>&1 && refuse "user $u exists already; remove it first (userdel -r $u)"
done
getent group developers >/dev/null && refuse "group developers exists already; remove it first (groupdel developers)"
getent group testers >/dev/null || { groupadd testers; state_set made-testers 1; }
user_add pat
user_add ken
user_add lou
state_set pat-hash "$(getent shadow pat | cut -d: -f2)"
# A file ken owns outside his home directory.
echo "ken's report" >/var/tmp/ken-report.txt
chown ken: /var/tmp/ken-report.txt
true
