# dpkg_did ACTION PACKAGE: dpkg's log shows the action since setup.
dpkg_did() {
	local since; since=$(state_get since)
	cat /var/log/dpkg.log 2>/dev/null | awk -v s="$since" -v a="$1" -v p="$2" \
		'($1 " " $2) >= s && $3 == a && ($4 == p || index($4, p ":") == 1) {ok = 1} END {exit !ok}'
}
gone() { ! dpkg-query -W -f '${Status}' "$1" 2>/dev/null | grep -Eq 'installed|config-files'; }

task 1 "cowsay installed, then removed (and purged)"
need "dpkg's log shows cowsay installed" 'dpkg_did install cowsay'
need "dpkg's log shows cowsay removed" 'dpkg_did remove cowsay'
need "cowsay is gone, configuration files too (dpkg -l)" 'gone cowsay'

task 2 "Owner of /usr/bin/ls and provider of ab found"
need "line 1 of /root/lab-answers/2 is the package that owns /usr/bin/ls" '[ "$(sed -n 1p /root/lab-answers/2 | tr -d "[:space:]" | cut -d: -f1)" = "$(dpkg -S /usr/bin/ls | cut -d: -f1)" ]'
need "line 2 is the package that provides the ab command" '[ "$(sed -n 2p /root/lab-answers/2 | tr -d "[:space:]" | cut -d: -f1)" = apache2-utils ]'

task 3 "hello downloaded and installed with dpkg -i"
need "a hello .deb was downloaded to /root" 'ls /root/hello_*.deb'
need "dpkg -c lists the .deb" 'dpkg -c /root/hello_*.deb | grep -q /usr/bin/hello'
need "hello is installed" 'dpkg-query -W -f "\${Status}" hello | grep -q "ok installed"'

task 4 "Time zone Europe/Berlin"
need "/etc/localtime points to Europe/Berlin" 'readlink -f /etc/localtime | grep -q "/Europe/Berlin$"'
need "/etc/timezone says Europe/Berlin" 'grep -qx Europe/Berlin /etc/timezone'
