if [ -n "$(state_get added-distro-info)" ]; then
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge distro-info >/dev/null 2>&1
fi
true
