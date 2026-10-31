id hana >/dev/null 2>&1 && refuse "user hana already exists; task 1 creates her. Remove her (userdel -r hana) and start the lab again."
getent passwd 1500 >/dev/null && refuse "UID 1500 is already taken (by $(getent passwd 1500 | cut -d: -f1)); task 1 needs it."
getent group qa >/dev/null && refuse "group qa already exists; task 1 creates it. Remove it and start the lab again."
id lou >/dev/null 2>&1 && refuse "user lou already exists; the lab creates him. Remove him and start the lab again."
user_add lou -c "Lou Park"
# Files lou leaves outside his home directory. Written by root first,
# then given to lou: root can't write to another user's file in a sticky
# directory such as /var/tmp (fs.protected_regular).
rm -rf /var/tmp/lou-build.log /srv/lou-reports
echo "build 41 finished" >/var/tmp/lou-build.log
mkdir -p /srv/lou-reports
echo "quarter,total" >/srv/lou-reports/q3.csv
chown lou:lou /var/tmp/lou-build.log /srv/lou-reports /srv/lou-reports/q3.csv
true
