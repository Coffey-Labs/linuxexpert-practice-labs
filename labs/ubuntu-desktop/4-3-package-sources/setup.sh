command -v snap >/dev/null || refuse "this lab needs snapd (apt install snapd)"
command -v add-apt-repository >/dev/null || pkg_install software-properties-common
grep -rqs 'git-core/ppa' /etc/apt/sources.list /etc/apt/sources.list.d/ &&
	refuse "the git-core PPA is already set up; remove it first (add-apt-repository --remove ppa:git-core/ppa)"
snap list hello >/dev/null 2>&1 && refuse "the hello snap is installed; remove it first (snap remove --purge hello)"
apt-cache policy git 2>/dev/null | grep -q 'Candidate:.*ppa' && refuse "git's candidate version comes from a PPA; remove the PPA first"

pkg_installed git || pkg_install git
state_set git-version "$(dpkg-query -W -f '${Version}' git)"
if pkg_installed hello; then
	state_set had-hello 1
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge hello >/dev/null
fi
# Task 2 looks in apt's history from here on.
state_set since "$(date '+%Y-%m-%d  %H:%M:%S')"
