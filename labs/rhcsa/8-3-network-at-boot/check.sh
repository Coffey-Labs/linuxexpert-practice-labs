UUID=$(state_get uuid) SETUP_BOOT=$(state_get setup-boot)
prof() { nmcli -g "$1" connection show "$UUID" 2>/dev/null; }

task1_needs() {
	need "the profile eth1-static still exists" '[ -n "$(prof connection.id)" ]'
	need "eth1-static comes up at boot (autoconnect yes)" '[ "$(prof connection.autoconnect)" = yes ]'
	need "eth1 is connected with eth1-static" '[ "$(nmcli -g GENERAL.STATE device show eth1 | cut -d" " -f1)" = 100 ] && [ "$(nmcli -g GENERAL.CON-UUID device show eth1)" = "$UUID" ]'
	need "eth1 has 192.168.50.10/24" 'ip -o addr show dev eth1 | grep -q " 192\.168\.50\.10/24 "'
}

task 1 "eth1-static comes up at boot"
task1_needs

task 2 "Booted once with autoconnect off, then back on and up"
need "a boot since the lab started had eth1-static set to no and eth1 not connected" 'awk -v b="$SETUP_BOOT" "\$1 != b && \$2 == \"autoconnect=no\" && \$3 != \"state=100\" {f = 1} END {exit !f}" "$LAB_STATE/watch.log"'
task1_needs
