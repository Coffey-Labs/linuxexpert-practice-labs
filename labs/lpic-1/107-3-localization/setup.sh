locale -a 2>/dev/null | grep -qix 'de_DE.utf-\?8' &&
	refuse "the de_DE.UTF-8 locale is installed already; task 1 installs it"
printf '%s\n' banana Apple cherry apple Banana Zebra zebra Cherry >/root/words.txt
rm -f /root/latin1.txt /root/utf8.txt
is_rhel && ! pkg_installed glibc-langpack-de && state_set langpack 1
[ -f /etc/locale.gen ] && cp -a /etc/locale.gen "$LAB_STATE/locale.gen"
ls /var/lib/locales/supported.d >"$LAB_STATE/supported-d" 2>/dev/null || true
true
