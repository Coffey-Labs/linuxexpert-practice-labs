export DEBIAN_FRONTEND=noninteractive
removed=
for f in $(grep -rls 'git-core/ppa' /etc/apt/sources.list.d/ 2>/dev/null); do rm -f "$f"; removed=1; done
[ -n "$removed" ] && apt-get -qq update >/dev/null 2>&1
gitver=$(state_get git-version)
if [ -n "$gitver" ] && [ "$(dpkg-query -W -f '${Version}' git 2>/dev/null)" != "$gitver" ]; then
	apt-get -y -qq install --allow-downgrades "git=$gitver" "git-man=$gitver" >/dev/null 2>&1
fi
if [ -n "$(state_get had-hello)" ]; then
	apt-get -y -qq install hello >/dev/null 2>&1
elif pkg_installed hello; then
	apt-get -y -qq purge hello >/dev/null 2>&1
fi
snap list hello >/dev/null 2>&1 && snap remove --purge hello >/dev/null 2>&1
rm -f /root/hello_*.deb
true
