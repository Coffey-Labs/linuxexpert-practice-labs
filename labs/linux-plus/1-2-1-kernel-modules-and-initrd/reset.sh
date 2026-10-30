for f in /etc/modprobe.d/*.conf /etc/modules-load.d/*.conf; do
	[ -f "$f" ] && grep -qw dummy "$f" || continue
	sed -i '/\bdummy\b/d' "$f"
	grep -q '[^[:space:]]' "$f" || rm -f "$f"
done
[ -f /etc/modules ] && sed -i '/^[[:space:]]*dummy[[:space:]]*$/d' /etc/modules
modprobe -r dummy 2>/dev/null
true
