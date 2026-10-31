rm -rf /srv/finance
H=$(state_get home)
[ -n "$H" ] && rm -rf "$H/private"
for u in ana ben; do gpasswd -d "$u" finance >/dev/null 2>&1; done
groupdel finance 2>/dev/null
true
