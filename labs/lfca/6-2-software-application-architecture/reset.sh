rm -f /root/shop.db
if [ -s "$LAB_STATE/not-installed" ]; then
	if is_rhel; then
		dnf -y -q remove $(cat "$LAB_STATE/not-installed") >/dev/null 2>&1
	else
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq --autoremove purge $(cat "$LAB_STATE/not-installed") >/dev/null 2>&1
	fi
fi
true
