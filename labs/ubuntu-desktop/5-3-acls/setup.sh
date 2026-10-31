[ -e /srv/shared ] && refuse "/srv/shared already exists; move it away first"
[ -e /tmp/new ] && refuse "/tmp/new already exists; remove it first"
for u in alice bob; do id "$u" >/dev/null 2>&1 && refuse "user $u already exists; remove it first"; done
getent group designers >/dev/null && refuse "group designers already exists; remove it first"

if ! pkg_installed acl; then
	pkg_install acl
	state_set added-acl 1
fi
groupadd designers
user_add alice
user_add bob
usermod -aG designers bob
