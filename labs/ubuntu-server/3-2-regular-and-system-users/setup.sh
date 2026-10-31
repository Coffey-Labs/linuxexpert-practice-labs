id reportsvc >/dev/null 2>&1 && refuse "a user reportsvc already exists; remove it and start again"
[ -e /var/lib/reportsvc ] && refuse "/var/lib/reportsvc already exists; move it away and start again"
ss -Hltn 'sport = :8080' | grep -q . && refuse "something already listens on port 8080; stop it and start again"
ls /etc/systemd/system >"$LAB_STATE/units-before"
user_add maria
user_add kiosk -s /usr/sbin/nologin
user_add buildbot -r -s /bin/bash
