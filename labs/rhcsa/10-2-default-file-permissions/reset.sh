for f in /etc/profile.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/profile-d" 2>/dev/null && continue
	grep -q umask "$f" && rm -f "$f"
done
true
