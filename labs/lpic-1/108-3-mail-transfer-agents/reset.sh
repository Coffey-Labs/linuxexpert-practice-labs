rm -f /home/alice/.forward
if [ -f "$LAB_STATE/aliases" ]; then cp -a "$LAB_STATE/aliases" /etc/aliases; else rm -f /etc/aliases; fi
# The packages the tasks installed.
rm_pkgs=()
for p in postfix s-nail mailx mailutils bsd-mailx; do
	grep -qxF "$p" "$LAB_STATE/had-pkgs" 2>/dev/null && continue
	pkg_installed "$p" && rm_pkgs+=("$p")
done
if [ ${#rm_pkgs[@]} -gt 0 ]; then
	systemctl stop postfix 2>/dev/null
	if is_rhel; then
		dnf -y -q remove "${rm_pkgs[@]}" >/dev/null 2>&1
	else
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge "${rm_pkgs[@]}" >/dev/null 2>&1
	fi
fi
rm -f /etc/aliases.db /etc/aliases.lmdb
[ -f /etc/aliases ] && command -v newaliases >/dev/null && newaliases 2>/dev/null
users_remove
rm -f /var/mail/alice /var/mail/bob /var/spool/mail/alice /var/spool/mail/bob
true
