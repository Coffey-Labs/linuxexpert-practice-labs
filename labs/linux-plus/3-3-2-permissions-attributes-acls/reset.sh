chattr -i /srv/team/locked 2>/dev/null
rm -rf /srv/team
if id acltest >/dev/null 2>&1; then
	pkill -KILL -u acltest 2>/dev/null
	userdel -r acltest 2>/dev/null
fi
users_remove
getent group labteam >/dev/null && groupdel labteam
true
