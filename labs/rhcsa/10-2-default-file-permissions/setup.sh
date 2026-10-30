ls -A /etc/profile.d >"$LAB_STATE/profile-d"
user_add alice
user_add bob
for u in alice bob; do
	m=$(runuser -l "$u" -c umask 2>/dev/null)
	[ "$m" != 0077 ] && [ "$m" != 0027 ] || refuse "$u's login shell already has umask $m; remove the system-wide umask line and start again"
done
