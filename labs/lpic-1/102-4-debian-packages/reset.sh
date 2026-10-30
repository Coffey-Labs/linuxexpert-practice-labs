for p in mc hello; do
	dpkg-query -W -f '${Status}' "$p" 2>/dev/null | grep -Eq ' (installed|config-files)$' &&
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge "$p" >/dev/null 2>&1
done
if [ -n "$(state_get had-mc)" ]; then
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq install mc >/dev/null 2>&1
elif [ -z "$(state_get had-mc-data)" ] && pkg_installed mc-data; then
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge mc-data >/dev/null 2>&1
fi
rm -f /root/hello_*.deb
tz=$(state_get tz)
if [ -n "$tz" ] && [ -e "/usr/share/zoneinfo/$tz" ]; then
	ln -sf "/usr/share/zoneinfo/$tz" /etc/localtime
	echo "$tz" >/etc/timezone
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive tzdata >/dev/null 2>&1
fi
true
