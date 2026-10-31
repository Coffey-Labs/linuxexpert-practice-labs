installed_pkgs() { dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' 2>/dev/null | awk '$1 ~ /^.i/ {print $2}' | sort -u; }
. /etc/os-release
command -v unattended-upgrade >/dev/null || refuse "this lab needs unattended-upgrades installed (apt install unattended-upgrades)"
[ -f /etc/apt/apt.conf.d/50unattended-upgrades ] || refuse "/etc/apt/apt.conf.d/50unattended-upgrades is missing; reinstall unattended-upgrades"
unattended-upgrade --dry-run --debug 2>&1 | grep 'Allowed origins' | grep -q "a=$VERSION_CODENAME-updates" &&
	refuse "unattended-upgrades already allows $VERSION_CODENAME-updates; comment it out in /etc/apt/apt.conf.d/ first"
pkg_installed libnl-3-200 || refuse "this lab needs libnl-3-200 installed"

cp -a /etc/apt/apt.conf.d/50unattended-upgrades "$LAB_STATE/50unattended-upgrades"
ls /etc/apt/apt.conf.d/ >"$LAB_STATE/aptconf-files"
pkg_installed aptitude && state_set had-aptitude 1
pkg_installed nano || pkg_install nano
installed_pkgs >"$LAB_STATE/pkgs-before"
echo '# le-lab: a local change; it goes away when nano is purged' >>/etc/nanorc
# Task 2 looks in dpkg's log from here on.
state_set since "$(date '+%Y-%m-%d %H:%M:%S')"
