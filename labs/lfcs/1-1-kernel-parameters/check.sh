task 1 "IPv4 forwarding on until the next reboot only" self

task 2 "Forwarding on and swappiness 10, in /etc/sysctl.d/90-lab.conf"
need "/etc/sysctl.d/90-lab.conf sets net.ipv4.ip_forward = 1" 'grep -Eq "^[[:space:]]*net[./]ipv4[./]ip_forward[[:space:]]*=[[:space:]]*1[[:space:]]*$" /etc/sysctl.d/90-lab.conf'
need "/etc/sysctl.d/90-lab.conf sets vm.swappiness = 10" 'grep -Eq "^[[:space:]]*vm[./]swappiness[[:space:]]*=[[:space:]]*10[[:space:]]*$" /etc/sysctl.d/90-lab.conf'
need "net.ipv4.ip_forward is 1 now" '[ "$(sysctl -n net.ipv4.ip_forward)" = 1 ]'
need "vm.swappiness is 10 now" '[ "$(sysctl -n vm.swappiness)" = 10 ]'

task 3 "IPv6 off on lab0 only, persistently"
need "interface lab0 exists" '[ -d /sys/class/net/lab0 ]'
need "lab0 has no IPv6 addresses" '[ -z "$(ip -6 -o addr show dev lab0)" ]'
need "lab1 still has an IPv6 address" '[ -n "$(ip -6 -o addr show dev lab1)" ]'
need "lo still has ::1" 'ip -6 -o addr show dev lo | grep -q "::1/128"'
need "the main interface keeps its IPv6 addresses" '[ "$(state_get main-v6)" != yes ] || [ -n "$(ip -6 -o addr show dev "$(state_get main-if)")" ]'
need "a setting that survives a reboot turns IPv6 off on lab0" '
	cat /etc/sysctl.conf /etc/sysctl.d/*.conf /run/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf 2>/dev/null | tr / . |
		grep -Eq "^[[:space:]]*net\.ipv6\.conf\.lab0\.disable_ipv6[[:space:]]*=[[:space:]]*1" ||
	grep -rqs lab0 /etc/NetworkManager/system-connections /etc/systemd/network /etc/netplan'

task 4 "Boot parameter audit=1 on every installed kernel"
if is_rhel; then
	need "every boot entry has audit=1" '[ -n "$(grubby --info=ALL | grep "^args=")" ] && ! grubby --info=ALL | grep "^args=" | grep -Ev "[\" ]audit=1[\" ]"'
else
	need "/etc/default/grub adds audit=1" 'grep -hEs "^[[:space:]]*GRUB_CMDLINE_LINUX(_DEFAULT)?=" /etc/default/grub /etc/default/grub.d/*.cfg | grep -Eq "[\" ]audit=1[\" ]"'
	need "every kernel in /boot/grub/grub.cfg has audit=1" '[ -n "$(awk "\$1 == \"linux\"" /boot/grub/grub.cfg)" ] && ! awk "\$1 == \"linux\"" /boot/grub/grub.cfg | grep -Ev "[[:space:]]audit=1([[:space:]]|$)"'
fi
need "the running kernel was booted with audit=1 (reboot)" 'grep -Eq "(^| )audit=1( |$)" /proc/cmdline'

task 5 "The dummy module loads at every boot with two devices"
need "dummy is set to load at boot" '
	cat /etc/modules-load.d/*.conf /run/modules-load.d/*.conf /usr/lib/modules-load.d/*.conf /etc/modules 2>/dev/null | grep -Eq "^[[:space:]]*dummy[[:space:]]*$" ||
	grep -Eq "modules[-_]load=([^ ]*,)?dummy" /proc/cmdline'
need "modprobe gives dummy numdummies=2 (the last setting wins)" 'modprobe --show-depends dummy 2>/dev/null | grep -o "numdummies=[0-9]*" | tail -n1 | grep -qx numdummies=2 || grep -q "dummy.numdummies=2" /proc/cmdline'
need "the dummy module is loaded" '[ -d /sys/module/dummy ]'
need "ip -br link shows two dummy devices" '[ "$(ip -br link | grep -c dummy)" = 2 ]'
