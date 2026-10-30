f=$(state_get changed-file)
if [ -n "$f" ] && [ -f "$LAB_STATE/original" ]; then
	cp -a "$LAB_STATE/original" "$f"
	is_rhel && restorecon "$f" 2>/dev/null
fi
if is_rhel; then
	dnf -q versionlock delete curl >/dev/null 2>&1
else
	apt-mark unhold curl >/dev/null 2>&1
	if [ "$(state_get had-dig)" = yes ]; then
		want=bind9-dnsutils
		[ "$(state_get had-ubuntu-standard)" = yes ] && want="$want ubuntu-standard"
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq install $want >/dev/null 2>&1
	fi
fi
true
