h=$(state_get hostname); [ -n "$h" ] && hostnamectl set-hostname "$h"
tz=$(state_get timezone); [ -n "$tz" ] && timedatectl set-timezone "$tz"
for f in $(grep -Els '^[[:space:]]*vm[./]swappiness[[:space:]]*=[[:space:]]*20[[:space:]]*$' /etc/sysctl.d/*.conf); do
	sed -i -E '/^[[:space:]]*vm[./]swappiness[[:space:]]*=[[:space:]]*20[[:space:]]*$/d' "$f"
	grep -Eq '^[[:space:]]*[^#[:space:]]' "$f" || rm -f "$f"
done
s=$(state_get swappiness); [ -n "$s" ] && sysctl -qw vm.swappiness="$s"
true
