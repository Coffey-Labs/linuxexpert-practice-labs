swapoff /swapfile /var/swap.old 2>/dev/null
rm -f /swapfile /var/swap.old
# Swap lines in /etc/fstab that weren't there before go (the spare disk's
# swap is turned off when the disk is removed).
awk 'NR == FNR { keep[$0] = 1; next }
	!/^[[:space:]]*#/ && $3 == "swap" && !($0 in keep) { next }
	{ print }' "$LAB_STATE/fstab-swap" /etc/fstab >/etc/fstab.le-lab && cat /etc/fstab.le-lab >/etc/fstab
rm -f /etc/fstab.le-lab
systemctl daemon-reload
# Swappiness settings added since setup go, and the old value comes back.
for f in /etc/sysctl.conf /etc/sysctl.d/*.conf; do
	[ -f "$f" ] || continue
	grep -qxF "$f" "$LAB_STATE/sysctl-files" 2>/dev/null && continue
	grep -qE '^[[:space:]]*vm[./]swappiness' "$f" || continue
	sed -i -E '/^[[:space:]]*vm[./]swappiness/d' "$f"
	[ "$f" != /etc/sysctl.conf ] && ! grep -qEv '^[[:space:]]*(#|$)' "$f" && rm -f "$f"
done
old=$(state_get swappiness)
[ -n "$old" ] && sysctl -qw vm.swappiness="$old"
true
