if id hardtest >/dev/null 2>&1; then
	pkill -KILL -u hardtest 2>/dev/null
	userdel -r hardtest 2>/dev/null
fi
# toor shares root's UID: take its lines out rather than run userdel.
sed -i '/^toor:/d' /etc/passwd /etc/shadow
if is_debian && [ -z "$(state_get had-pwquality)" ] && pkg_installed libpam-pwquality; then
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge libpam-pwquality >/dev/null 2>&1
fi
true
