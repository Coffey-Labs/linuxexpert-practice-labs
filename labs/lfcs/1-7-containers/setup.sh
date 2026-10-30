pkg_installed podman || pkg_install podman
user_add alice
# Nothing from the tasks yet.
for c in web systemd-web; do
	if podman container exists "$c" 2>/dev/null; then
		die "a container named $c already exists; remove it first, or run le-lab reset"
	fi
done
[ ! -e /etc/containers/systemd/web.container ] || die "/etc/containers/systemd/web.container already exists; remove it first"
true
