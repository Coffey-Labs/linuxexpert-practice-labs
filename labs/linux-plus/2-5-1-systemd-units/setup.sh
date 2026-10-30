for f in /etc/systemd/system/labbeat.service /etc/systemd/system/labbeat.timer /etc/systemd/system/atd.service.d; do
	[ ! -e "$f" ] || refuse "$f already exists; remove it first"
done
pkg_installed at && state_set had-at 1
pkg_installed at || pkg_install at
enabled atd && state_set atd-enabled 1
systemctl disable --now --quiet atd 2>/dev/null
true
