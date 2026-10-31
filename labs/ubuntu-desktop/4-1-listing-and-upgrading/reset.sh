for p in $(comm -13 "$LAB_STATE/holds-before" <(apt-mark showhold | sort) 2>/dev/null); do
	apt-mark unhold "$p" >/dev/null 2>&1
done
if snap list hello >/dev/null 2>&1 && ! grep -qx hello "$LAB_STATE/snaps-before" 2>/dev/null; then
	snap remove --purge hello >/dev/null 2>&1
fi
true
