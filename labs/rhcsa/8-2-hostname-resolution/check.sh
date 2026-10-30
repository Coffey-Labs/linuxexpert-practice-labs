task 1 "Hostname server1.example.com"
need "hostname prints server1.example.com" '[ "$(hostname)" = server1.example.com ]'
need "hostname -s prints server1" '[ "$(hostname -s)" = server1 ]'
need "/etc/hostname has server1.example.com (it lasts a reboot)" 'grep -qx server1.example.com /etc/hostname'

task 2 "web1 and web1.example.com resolve to 192.168.50.20 locally"
need "getent hosts web1 prints 192.168.50.20 web1.example.com web1" 'getent hosts web1 | tr -s " \t" " " | grep -qx "192\.168\.50\.20 web1\.example\.com web1"'
need "web1.example.com resolves to 192.168.50.20" 'getent hosts web1.example.com | grep -q "^192\.168\.50\.20[[:space:]]"'
need "web1 is in /etc/hosts" 'grep -Eq "^192\.168\.50\.20[[:space:]]" /etc/hosts'

task 3 "DNS server 192.168.50.1 and search domain example.com"
need "the eth1 profile (or another saved one) has DNS server 192.168.50.1" 'grep -rqs "^dns=.*192\.168\.50\.1" /etc/NetworkManager/system-connections'
need "the profile has search domain example.com" 'grep -rqs "^dns-search=.*example\.com" /etc/NetworkManager/system-connections'
need "/etc/resolv.conf has nameserver 192.168.50.1" 'grep -q "^nameserver 192\.168\.50\.1$" /etc/resolv.conf'
need "/etc/resolv.conf has search example.com" 'grep -Eq "^search( .*)? example\.com( |$)" /etc/resolv.conf'
