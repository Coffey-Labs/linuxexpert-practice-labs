rm -f /tmp/a.qcow2 /tmp/a.raw /tmp/b.qcow2
true
# The packages task 1 installed, if they weren't there before the lab.
if [ -s "$LAB_STATE/not-installed" ]; then
	say "Removing the packages task 1 installed..."
	if is_rhel; then
		dnf -y -q remove $(cat "$LAB_STATE/not-installed") >/dev/null 2>&1
	else
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq --autoremove purge $(cat "$LAB_STATE/not-installed") >/dev/null 2>&1
	fi
fi
true
