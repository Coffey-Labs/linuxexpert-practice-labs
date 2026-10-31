saved=$LAB_STATE/saved
for f in profile bash.bashrc; do
	[ -f "$saved/$f" ] && cp -a "$saved/$f" /etc/$f
done
[ -f "$saved/limits.conf" ] && cp -a "$saved/limits.conf" /etc/security/limits.conf
for pair in "/etc/profile.d profile-d" "/etc/security/limits.d limits-d"; do
	set -- $pair
	[ -f "$LAB_STATE/$2" ] || continue
	for f in "$1"/*; do
		[ -f "$f" ] || continue
		grep -qxF "${f##*/}" "$LAB_STATE/$2" || rm -f "$f"
	done
done
true
