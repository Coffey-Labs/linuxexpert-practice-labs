for f in /root/venv /root/src; do [ ! -e "$f" ] || refuse "$f already exists; move it away first"; done
if is_rhel; then
	pkg_installed htop && refuse "htop is installed; remove it first (task 1 installs it from EPEL)"
	pkg_installed epel-release && state_set had-epel 1
	dnf repolist --enabled 2>/dev/null | grep -q '^crb ' && state_set had-crb 1
else
	update-alternatives --query editor >/dev/null 2>&1 || refuse "there is no editor alternative to choose from"
	update-alternatives --auto editor >/dev/null 2>&1
fi
true
