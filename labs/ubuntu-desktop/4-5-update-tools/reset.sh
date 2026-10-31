installed_pkgs() { dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' 2>/dev/null | awk '$1 ~ /^.i/ {print $2}' | sort -u; }
# unattended-upgrades as it was, without files added for it.
if [ -f "$LAB_STATE/50unattended-upgrades" ]; then
	cp -a "$LAB_STATE/50unattended-upgrades" /etc/apt/apt.conf.d/50unattended-upgrades
	for f in /etc/apt/apt.conf.d/*; do
		grep -qx "${f##*/}" "$LAB_STATE/aptconf-files" && continue
		grep -qiE 'Unattended-Upgrade|Origins' "$f" && rm -f "$f"
	done
fi
# Packages the tasks installed (aptitude and what it brought in).
if [ -z "$(state_get had-aptitude)" ] && [ -f "$LAB_STATE/pkgs-before" ]; then
	added=$(comm -13 "$LAB_STATE/pkgs-before" <(installed_pkgs))
	[ -n "$added" ] && DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $added >/dev/null 2>&1
fi
pkg_installed nano || DEBIAN_FRONTEND=noninteractive apt-get -y -qq install nano >/dev/null 2>&1
[ -f /etc/nanorc ] && sed -i '/^# le-lab:/d' /etc/nanorc
true
