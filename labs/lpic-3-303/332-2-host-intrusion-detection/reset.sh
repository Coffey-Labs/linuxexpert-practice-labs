# Task 2's file, as it was.
f=$(state_get changed)
[ -n "$f" ] && [ -f "$LAB_STATE/changed.orig" ] && cp -a "$LAB_STATE/changed.orig" "$f"
# Audit rules files the lab didn't find.
for r in /etc/audit/rules.d/*; do
	[ -e "$r" ] || continue
	grep -qxF "${r##*/}" "$LAB_STATE/rules-d" 2>/dev/null || rm -f "$r"
done
command -v augenrules >/dev/null && augenrules --load >/dev/null 2>&1
for c in /etc/cron.d/*; do grep -qs /root/aide/lab.conf "$c" && rm -f "$c"; done
rm -rf /root/aide /root/oscap-results.xml /tmp/le-rules
# The packages installed since setup started, and only those: not the
# dependencies they leave unneeded that were there before.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
if [ -s "$LAB_STATE/pkgs-before" ]; then
	new=$(pkgs_now | comm -13 "$LAB_STATE/pkgs-before" - | grep -Ev '^(kernel|linux-)')
	if [ -n "$new" ]; then
		say "Removing the packages installed since the lab started..."
		if is_rhel; then
			dnf -y -q remove --setopt=clean_requirements_on_remove=False $new >/dev/null 2>&1
		else
			DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $new >/dev/null 2>&1
		fi
	fi
fi
grep -qx rkhunter <<<"${new:-}" && rm -rf /var/lib/rkhunter /var/log/rkhunter.log*
true
