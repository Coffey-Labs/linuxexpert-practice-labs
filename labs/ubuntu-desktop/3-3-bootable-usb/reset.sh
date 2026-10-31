installed_pkgs() { dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' 2>/dev/null | awk '$1 ~ /^.i/ {print $2}' | sort -u; }
rm -rf /root/usb /root/test.iso
if [ -z "$(state_get had-xorriso)" ] && [ -f "$LAB_STATE/pkgs-before" ]; then
	# xorriso and the libraries it brought in.
	added=$(comm -13 "$LAB_STATE/pkgs-before" <(installed_pkgs) | grep -E '^(xorriso|libburn|libisofs|libisoburn|libjte)' || true)
	[ -n "$added" ] && DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $added >/dev/null 2>&1
fi
true
