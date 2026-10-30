rm -f /tmp/s.conf
# Startup files as they were before the lab.
if [ -f "$LAB_STATE/kept" ]; then
	while read -r f; do
		[ -e "$LAB_STATE/saved$f" ] || continue
		rm -rf "$f"; cp -a "$LAB_STATE/saved$f" "$f"
	done <"$LAB_STATE/kept"
fi
if [ -f "$LAB_STATE/absent" ]; then
	while read -r f; do case $f in *'*'*) ;; *) rm -rf "$f" ;; esac; done <"$LAB_STATE/absent"
fi
command -v restorecon >/dev/null && restorecon -R /etc/environment /etc/profile.d /root /home 2>/dev/null
true
