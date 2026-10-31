get() { nmcli -g "$1" connection show office 2>/dev/null; }
uuid=$(get connection.uuid)
is_task2() { [ "$(get ipv4.method)" = auto ] && [ -z "$(get ipv4.addresses)" ] && [ -z "$(get ipv4.gateway)" ] && [ "$(get ipv4.ignore-auto-dns)" = yes ]; }

task 1 "Profile office for lab0: 10.10.10.50/24, not active"
need "a profile office exists (nmcli connection show)" '[ -n "$uuid" ]'
need "it's for interface lab0" '[ "$(get connection.interface-name)" = lab0 ]'
need "it has the address 10.10.10.50/24 and gateway 10.10.10.1 (or DHCP after task 2)" '{ [ "$(get ipv4.method)" = manual ] && [ "$(get ipv4.addresses)" = 10.10.10.50/24 ] && [ "$(get ipv4.gateway)" = 10.10.10.1 ]; } || is_task2'
need "its DNS server is 10.10.10.1" '[ "$(get ipv4.dns)" = 10.10.10.1 ]'
need "it isn't active" '! nmcli -g NAME connection show --active | grep -qx office'
need "it's stored as /etc/netplan/90-NM-$uuid.yaml" '[ -f "/etc/netplan/90-NM-$uuid.yaml" ]'

task 2 "office uses DHCP but keeps DNS 10.10.10.1"
need "a profile office exists" '[ -n "$uuid" ]'
need "ipv4.method is auto" '[ "$(get ipv4.method)" = auto ]'
need "the old address and gateway are cleared" '[ -z "$(get ipv4.addresses)" ] && [ -z "$(get ipv4.gateway)" ]'
need "DNS servers from DHCP are ignored (ipv4.ignore-auto-dns yes)" '[ "$(get ipv4.ignore-auto-dns)" = yes ]'
need "the DNS server is still 10.10.10.1" '[ "$(get ipv4.dns)" = 10.10.10.1 ]'
