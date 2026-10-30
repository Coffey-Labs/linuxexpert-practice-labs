for f in /swapfile /var/swap.old; do
	[ -e "$f" ] && die "this lab needs $f to be free; move or remove it first"
done
disk_add 0 1G >/dev/null
# What to put back on reset: the swap lines and swappiness settings there
# were before.
awk '!/^[[:space:]]*#/ && $3 == "swap"' /etc/fstab >"$LAB_STATE/fstab-swap"
grep -rlsE '^[[:space:]]*vm[./]swappiness' /etc/sysctl.conf /etc/sysctl.d >"$LAB_STATE/sysctl-files" || true
state_set swappiness "$(sysctl -n vm.swappiness)"
# The old swap file for task 3.
dd if=/dev/zero of=/var/swap.old bs=1M count=128 status=none
chmod 600 /var/swap.old
mkswap /var/swap.old >/dev/null
swapon /var/swap.old
echo '/var/swap.old none swap defaults 0 0' >>/etc/fstab
# Swappiness already at 10 would pass task 4 untouched.
[ "$(sysctl -n vm.swappiness)" != 10 ] || sysctl -qw vm.swappiness=60
