export DEBIAN_FRONTEND=noninteractive
snap list htop >/dev/null 2>&1 && snap remove --purge htop >/dev/null 2>&1
for set in $(snap saved htop 2>/dev/null | awk 'NR > 1 && $2 == "htop" {print $1}'); do
	grep -qxF "$set" "$LAB_STATE/old-snapshots" 2>/dev/null || snap forget "$set" >/dev/null 2>&1
done
if [ -n "$(state_get had-htop)" ]; then
	pkg_installed htop || apt-get -y -qq install htop >/dev/null 2>&1
	if [ -n "$(state_get had-ubuntu-server)" ] && ! pkg_installed ubuntu-server; then
		apt-get -y -qq install ubuntu-server >/dev/null 2>&1
	fi
elif pkg_installed htop; then
	apt-get -y -qq purge htop >/dev/null 2>&1
fi
[ -z "$(state_get had-htoprc)" ] && rm -f /root/.config/htop/htoprc
true
