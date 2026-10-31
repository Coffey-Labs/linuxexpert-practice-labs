if command -v podman >/dev/null; then
	if [ -z "$(state_get had-podman)" ]; then
		podman system reset -f >/dev/null 2>&1
	else
		for p in 8080 8081; do
			for c in $(podman ps -q); do
				podman port "$c" 2>/dev/null | grep -Eq "^80/tcp -> .*:$p\$" && podman rm -f -t 0 "$c" >/dev/null 2>&1
			done
		done
		for c in $(podman ps -a -q --filter ancestor=localhost/mysite:1.0); do podman rm -f -t 0 "$c" >/dev/null 2>&1; done
		podman rm -f -t 0 db >/dev/null 2>&1
		podman volume rm -f dbdata >/dev/null 2>&1
		podman rmi -f localhost/mysite:1.0 >/dev/null 2>&1
	fi
fi
rm -rf /root/mysite
if [ -z "$(state_get had-podman)" ] && pkg_installed podman; then
	if is_rhel; then
		dnf -y -q remove podman >/dev/null 2>&1
	else
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq --autoremove purge podman >/dev/null 2>&1
	fi
fi
true
