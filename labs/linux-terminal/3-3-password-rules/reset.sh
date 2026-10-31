saved=$LAB_STATE/saved
if id dave >/dev/null 2>&1; then
	pkill -KILL -u dave 2>/dev/null
	userdel -r dave 2>/dev/null
fi
# Packages the task installed (pam-auth-update takes the line out again).
if [ -f "$LAB_STATE/packages" ]; then
	new=$(dpkg-query -W -f '${Package}\n' | grep -Fxv -f "$LAB_STATE/packages" |
		grep -E 'pwquality|crack|^wamerican$')
	[ -n "$new" ] && DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $new >/dev/null 2>&1
fi
if [ -f "$saved/common-password" ]; then
	cp -a "$saved/common-password" /etc/pam.d/common-password
	cp -a "$saved/login.defs" /etc/login.defs
	if [ -f "$saved/pwquality.conf" ]; then cp -a "$saved/pwquality.conf" /etc/security/pwquality.conf; fi
	rm -rf /etc/security/pwquality.conf.d
	[ -d "$saved/pwquality.conf.d" ] && cp -a "$saved/pwquality.conf.d" /etc/security/
fi
true
