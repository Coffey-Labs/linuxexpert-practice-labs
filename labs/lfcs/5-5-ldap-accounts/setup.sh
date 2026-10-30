for u in alice bob; do
	if grep -q "^$u:" /etc/passwd; then
		die "a local user $u exists; remove it first (the lab's $u comes from the directory)"
	fi
done
pkg_install openldap-clients/ldap-utils
hosts_add "127.0.0.1 ldap.example.org ldap"
# What reset puts back.
state_set sssd-enabled "$(systemctl is-enabled sssd 2>/dev/null)"
state_set oddjobd-enabled "$(systemctl is-enabled oddjobd 2>/dev/null)"
if is_rhel; then state_set authselect "$(authselect current -r 2>/dev/null)"; fi
true
