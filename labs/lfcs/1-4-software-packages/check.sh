task 1 "The package providing dig installed and named"
need "dig is installed" 'command -v dig'
need "/root/lab-answers/1 names the package that owns dig" '
	p=$(answer 1); f=$(readlink -f "$(command -v dig)")
	if is_rhel; then [ "$p" = "$(rpm -qf --qf "%{NAME}" "$f")" ]
	else o=$(dpkg -S "$f" | cut -d: -f1); [ "$p" = "$o" ] || [ "$p" = dnsutils ]; fi'

task 2 "A package from a third-party repository; the repository removed"
pkg=$(answer 2)
need "/root/lab-answers/2 names an installed package" '[ -n "$pkg" ] && pkg_installed "$pkg"'
if is_rhel; then
	need "the package came from a repository, not a local file" '
		r=$(dnf repoquery -q --installed --qf "%{from_repo}" "$pkg" | head -n1)
		[ -n "$r" ] && ! [[ "$r" =~ ^(@?System|@?commandline|anaconda)$ ]]'
	need "it isn't from the distribution's repositories" '
		r=$(dnf repoquery -q --installed --qf "%{from_repo}" "$pkg" | head -n1)
		! [[ "$r" =~ ^(baseos|appstream|crb|extras|highavailability|nfv|rt|sap|saphana|resilientstorage)$ ]] &&
		! rpm -q --qf "%{VENDOR}" "$pkg" | grep -Eqi "almalinux|red hat|rocky|centos"'
	need "its repository is no longer configured" '
		r=$(dnf repoquery -q --installed --qf "%{from_repo}" "$pkg" | head -n1)
		! dnf repolist --all -q | awk "NR > 1 {print \$1}" | grep -qxF "$r"'
else
	need "it isn't from the distribution" '! dpkg-query -W -f "\${Maintainer}" "$pkg" | grep -qi "ubuntu\.com\|debian\.org"'
	need "no configured repository offers it any more" '! apt-cache policy "$pkg" | grep -Eq "^[[:space:]]+[0-9]+ (https?|ftp|file|cdrom|mirror)[:+]"'
fi

task 3 "The changed openssh-server file found and restored"
f=$(state_get changed-file)
need "/root/lab-answers/3 holds the changed file's path" '[ "$(answer 3)" = "$f" ]'
if is_rhel; then
	need "rpm -V openssh-server no longer lists it" '! rpm -V openssh-server | grep -q "[[:space:]]$f\$"'
else
	need "dpkg --verify openssh-server no longer lists it" '! dpkg --verify openssh-server | grep -q "[[:space:]]$f\$"'
fi
need "the file is there" '[ -s "$f" ]'
need "sshd still listens on port 22" listening 22 tcp

task 4 "curl can't be upgraded"
if is_rhel; then
	need "curl is version-locked or excluded" '
		dnf -q versionlock list 2>/dev/null | grep -Eq "^curl-[0-9]" ||
		grep -Eq "^[[:space:]]*exclude(pkgs)?[[:space:]]*=.*(^|[ =,])curl([ ,*]|$)" /etc/dnf/dnf.conf'
else
	need "curl is on hold" 'apt-mark showhold | grep -qx curl'
fi
