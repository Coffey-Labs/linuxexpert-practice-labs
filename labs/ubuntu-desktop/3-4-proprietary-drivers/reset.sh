if [ -s "$LAB_STATE/pkgs-added" ]; then
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $(cat "$LAB_STATE/pkgs-added") >/dev/null 2>&1
fi
true
