W=$(state_get writer)

task 1 "The program that writes /etc/resolv.conf in /root/lab-answers/1"
if [ "$W" = resolved ]; then
	need "the answer names systemd-resolved" 'answer 1 | grep -q resolved'
elif [ "$W" = networkmanager ]; then
	need "the answer names NetworkManager" 'answer 1 | grep -Eq "networkmanager|^nm$"'
elif [ "$W" = resolvconf ]; then
	need "the answer names resolvconf" 'answer 1 | grep -q resolvconf'
else
	need "/root/lab-answers/1 names a program" '[ -n "$(answer 1)" ]'
fi

task 2 "example.org as a persistent search domain"
need "getent hosts www finds www.example.org" 'getent hosts www | grep -q "example\.org"'
if is_rhel; then
	need "the search domain is in NetworkManager's configuration" 'grep -rqs "example\.org" /etc/NetworkManager/system-connections /etc/NetworkManager/conf.d'
else
	need "the search domain is in netplan's, networkd's or resolved's configuration" 'conf_has /etc/netplan /etc/systemd/network /etc/systemd/resolved.conf /etc/systemd/resolved.conf.d "example\.org"'
fi

task 3 "fake.example.org: getent's answer noted, the line removed"
need "dig is installed" 'command -v dig'
need "the answer is 192.168.1.250" '[ "$(answer 3)" = 192.168.1.250 ]'
need "fake.example.org is no longer in /etc/hosts" '! grep -Eq "^[^#]*[[:space:]]fake\.example\.org([[:space:]]|$)" /etc/hosts'
