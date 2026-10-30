for d in /srv/devs /srv/secret /srv/reports; do
	[ -e "$d" ] && refuse "$d already exists; remove it and start again"
done
pkg_installed acl || pkg_install acl
getent group devs >/dev/null || { groupadd devs; state_set made-devs 1; }
user_add alice -G devs
user_add bob -G devs
user_add carol
mkdir -p /srv/reports
chmod 750 /srv/reports
echo 'Quarterly numbers' >/srv/reports/q3.txt
chmod 640 /srv/reports/q3.txt
setfacl -m u:bob:rx /srv/reports
setfacl -m u:bob:r /srv/reports/q3.txt
