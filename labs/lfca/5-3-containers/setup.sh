[ ! -e /root/mysite ] || refuse "/root/mysite already exists; move it away first"
if pkg_installed podman; then
	state_set had-podman 1
	podman container exists db 2>/dev/null && refuse "a container named db already exists; remove it first (podman rm -f db)"
	podman volume exists dbdata 2>/dev/null && refuse "a volume named dbdata already exists; remove it first (podman volume rm dbdata)"
fi
true
