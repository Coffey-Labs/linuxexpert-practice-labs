# swap_line NAME: NAME's line in /proc/swaps (Filename Type Size Used Priority).
swap_line() { awk -v n="$1" 'NR > 1 && $1 == n' /proc/swaps; }
# fstab_swap NAME: the options of NAME's swap line in /etc/fstab.
fstab_swap() { awk -v n="$1" '!/^[[:space:]]*#/ && $1 == n && $3 == "swap" {print $4}' /etc/fstab | head -n1; }
# Swap areas on block devices, as size-in-KiB priority.
dev_swaps() { awk 'NR > 1 && $2 == "partition" {print $3, $5}' /proc/swaps; }

task 1 "1 GiB swap file /swapfile, used at every boot"
need "/swapfile is in use as swap" '[ -n "$(swap_line /swapfile)" ]'
need "/swapfile is 1 GiB" 's=$(swap_line /swapfile | awk "{print \$3}"); [ "$s" -ge 1040000 ] && [ "$s" -le 1050000 ]'
need "/swapfile is in /etc/fstab" '[ -n "$(awk "!/^[[:space:]]*#/ && \$1 == \"/swapfile\" && \$3 == \"swap\"" /etc/fstab)" ]'

task 2 "512 MiB swap partition at priority 10, /swapfile at 5"
need "a 512 MiB swap partition is in use with priority 10" 'dev_swaps | awk "\$1 >= 512000 && \$1 <= 530000 && \$2 == 10 {ok = 1} END {exit !ok}"'
need "/swapfile is in use with priority 5" '[ "$(swap_line /swapfile | awk "{print \$5}")" = 5 ]'
need "/etc/fstab gives a swap partition pri=10" 'awk "!/^[[:space:]]*#/ && \$3 == \"swap\" && \$1 != \"/swapfile\" && \$4 ~ /(^|,)pri=10(,|$)/ {ok = 1} END {exit !ok}" /etc/fstab'
need "/etc/fstab gives /swapfile pri=5" 'fstab_swap /swapfile | grep -Eq "(^|,)pri=5(,|$)"'

task 3 "/var/swap.old off and gone for good"
need "/var/swap.old is no longer in use" '[ -z "$(swap_line /var/swap.old)" ]'
need "/var/swap.old is deleted" '[ ! -e /var/swap.old ]'
need "/etc/fstab no longer lists /var/swap.old" '! grep -Ev "^[[:space:]]*#" /etc/fstab | grep -q /var/swap.old'

task 4 "Swappiness 10, persistently"
need "vm.swappiness is 10 now" '[ "$(sysctl -n vm.swappiness)" = 10 ]'
need "a sysctl file sets it at boot" 'grep -rhsE "^[[:space:]]*vm[./]swappiness[[:space:]]*=" /etc/sysctl.conf /etc/sysctl.d | tail -n1 | grep -Eq "=[[:space:]]*10[[:space:]]*$"'
