# The client: SSSD, NSS and PAM as they were.
systemctl stop sssd 2>/dev/null
[ "$(state_get sssd-enabled)" = enabled ] || systemctl disable --quiet sssd 2>/dev/null
rm -f /etc/sssd/sssd.conf /etc/sssd/conf.d/*.conf
rm -rf /var/lib/sss/db/* /var/lib/sss/mc/* 2>/dev/null
if is_rhel; then
	a=$(state_get authselect)
	[ -n "$a" ] && authselect select $a --force >/dev/null 2>&1
	[ "$(state_get oddjobd-enabled)" = enabled ] || systemctl disable --now --quiet oddjobd 2>/dev/null
elif command -v pam-auth-update >/dev/null; then
	pam-auth-update --disable mkhomedir 2>/dev/null
fi
# The directory: OpenLDAP or 389 Directory Server, with its data.
systemctl disable --now --quiet slapd 2>/dev/null
if is_debian && pkg_installed slapd; then
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge slapd >/dev/null 2>&1
	rm -rf /var/lib/ldap /etc/ldap/slapd.d
elif is_rhel && pkg_installed openldap-servers; then
	dnf -y -q remove openldap-servers >/dev/null 2>&1
	rm -rf /etc/openldap/slapd.d /var/lib/ldap/*
fi
if command -v dsctl >/dev/null; then
	for i in $(dsctl -l 2>/dev/null); do dsctl "${i#slapd-}" remove --do-it >/dev/null 2>&1; done
fi
for u in alice bob; do
	grep -q "^$u:" /etc/passwd || rm -rf "/home/$u"
done
true
