rm -f /etc/yum.repos.d/lab.repo /etc/yum.repos.d/extras-mirror.repo
rm -rf /srv/repo
if [ -n "$(state_get had-semanage)" ]; then
	pkg_installed policycoreutils-python-utils || dnf -y -q install policycoreutils-python-utils >/dev/null
else
	pkg_installed policycoreutils-python-utils && dnf -y -q remove policycoreutils-python-utils >/dev/null
fi
dnf -q clean metadata >/dev/null 2>&1
true
