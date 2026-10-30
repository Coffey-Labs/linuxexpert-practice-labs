rm -rf /srv/devs /srv/secret /srv/reports
users_remove
[ -n "$(state_get made-devs)" ] && groupdel devs 2>/dev/null
true
