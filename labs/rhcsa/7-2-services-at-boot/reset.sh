systemctl disable --now --quiet le-lab-watch.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-watch.service /usr/local/lib/le-lab/watch.sh
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl unmask --quiet httpd 2>/dev/null
systemctl disable --now --quiet httpd 2>/dev/null
systemctl daemon-reload
if [ -z "$(state_get httpd-before)" ] && pkg_installed httpd; then
	say "Removing httpd..."
	dnf -y -q remove httpd >/dev/null 2>&1
fi
true
