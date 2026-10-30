for f in /etc/yum.repos.d/lab.repo /etc/yum.repos.d/extras-mirror.repo /srv/repo; do
	[ -e "$f" ] && refuse "$f already exists; the lab creates or uses it. Remove it and start the lab again."
done
pkg_install createrepo_c dnf-plugins-core
if pkg_installed policycoreutils-python-utils; then
	state_set had-semanage 1
	dnf -y -q remove policycoreutils-python-utils >/dev/null
fi
rpm -qa --qf '%{name}-%{version}-%{release}.%{arch}\n' | sort >"$LAB_STATE/rpms"
# Task 4 looks at transactions after this one.
state_set history-id "$(dnf -q history list 2>/dev/null | awk '$1 ~ /^[0-9]+$/ {print $1; exit}')"
peer_up
cat >/etc/yum.repos.d/extras-mirror.repo <<'X'
[extras-mirror]
name=AlmaLinux extras mirror
baseurl=http://mirror.lab.invalid/almalinux/extras/
enabled=1
gpgcheck=1
skip_if_unavailable=False
X
