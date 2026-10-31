for f in /etc/sudoers.d/* /etc/sudoers.d/.*; do
	[ -f "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/sudoers-d" 2>/dev/null || rm -f "$f"
done
[ -f "$LAB_STATE/sudoers" ] && cp -a "$LAB_STATE/sudoers" /etc/sudoers
true
