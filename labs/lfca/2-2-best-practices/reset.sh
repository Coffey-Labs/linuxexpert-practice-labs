systemctl disable --now --quiet le-lab-oldapp.service 2>/dev/null
systemctl unmask --quiet le-lab-oldapp.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-oldapp.service
systemctl daemon-reload
rm -rf /srv/le-oldapp /usr/local/lib/le-lab/httpd.py
rmdir /usr/local/lib/le-lab 2>/dev/null

if id erin >/dev/null 2>&1; then
	pkill -KILL -u erin 2>/dev/null
	userdel -r erin 2>/dev/null
fi
rm -rf /srv/erin /root/add-dev.sh /root/ansible
[ -n "$(state_get had-dot-ansible)" ] || rm -rf /root/.ansible
[ -n "$(state_get made-developers)" ] && groupdel developers 2>/dev/null

# Packages and nginx as they were.
if grep -qx nginx "$LAB_STATE/not-installed" 2>/dev/null; then
	systemctl disable --now --quiet nginx 2>/dev/null
else
	[ -n "$(state_get nginx-was-enabled)" ] || systemctl disable --quiet nginx 2>/dev/null
	[ -n "$(state_get nginx-was-active)" ] || systemctl stop nginx 2>/dev/null
fi
if [ -s "$LAB_STATE/not-installed" ]; then
	if is_rhel; then
		dnf -y -q remove $(cat "$LAB_STATE/not-installed") >/dev/null 2>&1
	else
		grep -qx nginx "$LAB_STATE/not-installed" && echo nginx-common >>"$LAB_STATE/not-installed"
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq --autoremove purge $(cat "$LAB_STATE/not-installed") >/dev/null 2>&1
	fi
fi
true
