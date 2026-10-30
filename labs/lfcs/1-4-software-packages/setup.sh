# No dig yet (task 1).
if is_rhel; then
	if pkg_installed bind-utils; then dnf -y -q remove bind-utils >/dev/null; fi
else
	if pkg_installed bind9-dnsutils; then
		pkg_installed ubuntu-standard && state_set had-ubuntu-standard yes
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq remove bind9-dnsutils >/dev/null 2>&1
		state_set had-dig yes
	fi
fi

# Change one character in a comment of an openssh-server file (task 3).
f=$(pick /etc/ssh/sshd_config /etc/default/ssh)
state_set changed-file "$f"
cp -a "$f" "$LAB_STATE/original"
if is_rhel; then
	grep -q '^#Port 22$' "$f" && sed -i 's/^#Port 22$/#Port 24/' "$f" || echo '#' >>"$f"
else
	grep -q '^# Options to pass to sshd$' "$f" && sed -i 's/^# Options to pass to sshd$/# Options to pass to sshD/' "$f" || echo '#' >>"$f"
fi

# curl not held (task 4).
if is_rhel; then
	dnf -q versionlock delete curl >/dev/null 2>&1 || true
else
	apt-mark unhold curl >/dev/null 2>&1 || true
fi
true
