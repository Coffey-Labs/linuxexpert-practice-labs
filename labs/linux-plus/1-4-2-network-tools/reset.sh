if systemctl is-active --quiet firewalld; then
	for p in 9000 5201; do
		[ -n "$(state_get fw-had-$p)" ] || firewall-cmd -q --remove-port=$p/tcp 2>/dev/null
	done
elif command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	for p in 9000 5201; do
		[ -n "$(state_get ufw-had-$p)" ] || { ufw delete allow $p/tcp; ufw delete allow $p; } >/dev/null 2>&1
	done
fi
true
# The packages task 4 installed, if they weren't there before the lab.
if [ -s "$LAB_STATE/not-installed" ]; then
	if is_rhel; then
		dnf -y -q remove $(cat "$LAB_STATE/not-installed") >/dev/null 2>&1
	else
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $(cat "$LAB_STATE/not-installed") >/dev/null 2>&1
	fi
fi
true
