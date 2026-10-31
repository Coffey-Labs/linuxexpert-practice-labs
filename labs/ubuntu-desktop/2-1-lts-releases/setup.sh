if ! command -v ubuntu-distro-info >/dev/null; then
	pkg_install distro-info
	state_set added-distro-info 1
fi
