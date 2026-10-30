getent group labteam >/dev/null && refuse "group labteam already exists; remove it and start again"
[ -e /srv/team ] && refuse "/srv/team already exists; remove it and start again"
id acltest >/dev/null 2>&1 && refuse "user acltest already exists; remove it and start again"
user_add pat
true
