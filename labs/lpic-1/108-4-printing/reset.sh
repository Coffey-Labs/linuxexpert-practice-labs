# Job history and the PDFs.
if command -v cancel >/dev/null; then cancel -a -x 2>/dev/null; fi
systemctl stop cups cups.socket cups.path 2>/dev/null
rm -rf /var/spool/cups/c[0-9]* /var/spool/cups/d[0-9]* /var/cache/cups/job.cache*
find /root /home -maxdepth 3 -name '*.pdf' -newer "$LAB_STATE/stamp" -path '*/PDF/*' -delete 2>/dev/null
find /root /home -maxdepth 3 -name '*.pdf' -newer "$LAB_STATE/stamp" -path '*/Desktop/*' -delete 2>/dev/null
rm -rf /var/spool/cups-pdf/ANONYMOUS/*
# The packages the tasks installed.
rm_pkgs=()
for p in cups cups-daemon cups-pdf printer-driver-cups-pdf cups-bsd cups-client cups-ipptool cups-ipp-utils epel-release; do
	grep -qxF "$p" "$LAB_STATE/had-pkgs" 2>/dev/null && continue
	pkg_installed "$p" && rm_pkgs+=("$p")
done
if [ ${#rm_pkgs[@]} -gt 0 ]; then
	if is_rhel; then
		dnf -y -q remove "${rm_pkgs[@]}" >/dev/null 2>&1
	else
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge "${rm_pkgs[@]}" >/dev/null 2>&1
	fi
fi
users_remove
# Settings dnf leaves behind.
rm -f /etc/cups/printers.conf* /etc/cups/cupsd.conf.rpmsave /etc/cups/ppd/*.ppd
true
