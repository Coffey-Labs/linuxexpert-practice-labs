command -v mandb >/dev/null || refuse "man-db isn't installed; install it (dnf install man-db man-pages) and start the lab again."
[ -f /usr/share/man/man5/systemd.timer.5.gz ] || refuse "the systemd man pages aren't installed (check tsflags=nodocs in /etc/dnf/dnf.conf)."
if [ -f /var/cache/man/index.db ]; then
	mv /var/cache/man/index.db "$LAB_STATE/index.db"
fi
