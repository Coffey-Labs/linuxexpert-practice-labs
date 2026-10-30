for f in $(grep -lsE '^[[:space:]]*blacklist[[:space:]]+pcspkr\b' /etc/modprobe.d/*.conf); do
	grep -qxF "$f" "$LAB_STATE/old-blacklists" 2>/dev/null && continue
	sed -i -E '/^[[:space:]]*blacklist[[:space:]]+pcspkr\b/d' "$f"
	[ -s "$f" ] || rm -f "$f"
done
modprobe pcspkr 2>/dev/null
true
