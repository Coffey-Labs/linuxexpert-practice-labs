pkg_installed mc && state_set had-mc 1
pkg_installed mc-data && state_set had-mc-data 1
for p in mc hello; do
	dpkg-query -W -f '${Status}' "$p" 2>/dev/null | grep -Eq ' (installed|config-files)$' &&
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge "$p" >/dev/null
done
state_set tz "$(timedatectl show -p Timezone --value)"
[ "$(state_get tz)" = Europe/Berlin ] && timedatectl set-timezone Etc/UTC
# Task 1 and 3 look in dpkg's log from here on.
state_set since "$(date '+%Y-%m-%d %H:%M:%S')"
