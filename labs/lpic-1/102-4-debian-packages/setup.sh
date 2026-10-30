for p in cowsay hello; do
	pkg_installed "$p" && DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge "$p" >/dev/null
done
state_set tz "$(timedatectl show -p Timezone --value)"
[ "$(state_get tz)" = Europe/Berlin ] && timedatectl set-timezone Etc/UTC
# Task 1 and 3 look in dpkg's log from here on.
state_set since "$(date '+%Y-%m-%d %H:%M:%S')"
