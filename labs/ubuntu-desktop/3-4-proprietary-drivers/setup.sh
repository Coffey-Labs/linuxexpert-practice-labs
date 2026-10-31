installed_pkgs() { dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' 2>/dev/null | awk '$1 ~ /^.i/ {print $2}' | sort -u; }
if ! command -v ubuntu-drivers >/dev/null; then
	installed_pkgs >"$LAB_STATE/pkgs-before"
	pkg_install ubuntu-drivers-common
	comm -13 "$LAB_STATE/pkgs-before" <(installed_pkgs) >"$LAB_STATE/pkgs-added"
fi
