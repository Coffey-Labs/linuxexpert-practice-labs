rm -f /root/words.txt /root/latin1.txt /root/utf8.txt
# The locale, if the lab's task installed it.
if [ -n "$(state_get langpack)" ] && pkg_installed glibc-langpack-de; then
	dnf -y -q remove glibc-langpack-de >/dev/null 2>&1
fi
if is_debian; then
	if [ -f "$LAB_STATE/locale.gen" ]; then cp -a "$LAB_STATE/locale.gen" /etc/locale.gen; fi
	for f in /var/lib/locales/supported.d/*; do
		[ -e "$f" ] || continue
		grep -qxF "${f##*/}" "$LAB_STATE/supported-d" 2>/dev/null || rm -f "$f"
	done
	for l in $(localedef --list-archive 2>/dev/null | grep -i '^de_DE'); do
		localedef --delete-from-archive "$l" 2>/dev/null
	done
fi
rm -rf /usr/lib/locale/de_DE.utf8 /usr/lib/locale/de_DE.UTF-8
true
