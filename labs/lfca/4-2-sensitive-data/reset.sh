rm -rf /root/leaky /root/customers.csv /root/customers.csv.gpg
if [ -z "$(state_get had-gnupg)" ]; then
	gpgconf --kill gpg-agent 2>/dev/null
	rm -rf /root/.gnupg
fi
if [ -s "$LAB_STATE/not-installed" ]; then
	if is_rhel; then
		dnf -y -q remove $(cat "$LAB_STATE/not-installed") >/dev/null 2>&1
	else
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq --autoremove purge $(cat "$LAB_STATE/not-installed") >/dev/null 2>&1
	fi
fi
# A gitleaks binary from upstream, if one was put here during the lab.
[ -n "$(state_get had-gitleaks-bin)" ] || { pkg_installed gitleaks || rm -f /usr/local/bin/gitleaks; }
true
