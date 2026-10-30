if pkg_installed mariadb; then
	say "Removing mariadb..."
	dnf -y -q remove mariadb >/dev/null 2>&1
fi
true
